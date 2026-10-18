# D1 draft, area E: DOS assets at run time (phase D2)

Draft of 2026-10-11 by design agent D1-E under `docs/verify/BRIEF-d1.md`. It is the proposed text of
the DESIGN.md subsection "DOS assets at run time" (12.5 onwards, the orchestrator numbers it). It
covers extension prompt 5.9, 7.6, D-1, 2.3 "No DOS bytes" and the `present/dos/` asset modules.
Nothing here is code, a build or a test result; the scratch checks named "scratch" are read-only
Python runs under `build/d1/scratch-E/` on `build/dosdata` (they print counts only).

Labels as DESIGN.md: **listing**, **docs**, **DOS file**, **DOS listing**, **inferred**,
**choice** (here written **Choice**, with the alternatives), **Open**. D0 drafts are cited by
document and section, in their corrected state of 2026-10-11: FORMATS, EXECUTABLE, DRIVER,
PALETTE, SPRITES, TIMING, SCENES, SCENES-PLAY, OPEN (all `docs/dos/`), DOS-PROFILE (`docs/`).

### Revision 3 (after RV2)

Applies `verify/ext-d1-review-rv2.md` as `verify/ext-d1-decisions.md` "Design review RV2" resolves it.
RV2 found E's interfaces consistent with A, B, C and D; the D2 implementer is building against them.
**No interface of this draft changes** (names, signatures, file ids, registry rows, enums and
constants as in Revision 2). Wording only:

1. **E.9.5 (B's E-B4, X8):** the pointer's index-to-ARGB conversion is the DOS profile's `cursor`
   callback (B 6.7, A 8.5), not A's route itself.
2. **E.10.3 (RV2-17):** the segment at `[DGROUP:640A]` holds both B's leader-font table (first 16
   bytes, the D7 row `LEADER_FONT`) and the "throne-room table"; both uses are recorded.
3. Interfaces used by other areas in Revision 3 (no change here): area C now calls
   `pdos_text_line(PDOS_F_CREDITS_TXT, i, &len)` and `pdos_text_line(PDOS_F_STORY_TXT, i, &len)` in
   E.8.1's form (RV2-9); area D reads the page-2 rectangles from `pdos_pic(PDOS_F_SP299_PIC)` inside
   `PDOS_PAGE2_ART_*` as E.9.2 says (RV2-8); K2's list in A 17 now includes E's `host.h` additions and
   their back ends (RV2-14).

### Revision 2 (after RV1)

Applies `verify/ext-d1-review-rv1.md` and the orchestrator's resolutions in
`verify/ext-d1-decisions.md` ("Area E" E.18-1..5, "Design review RV1").

1. **RV1-1 (blocker), RV1-16: new shape-cut module `pdos_shapes`** (E.9, replacing the old
   "Pointer shapes"). It reproduces the DOS start-up cut O5:1455 at activation from the decoded
   `SP299.PIC`, `TER257.PIC`, `SP257.PIC` and `TORCH.PIC`: 15 shape families from a 22-row cut
   table whose rectangles are constants citing their O5 addresses (user D6), the unit recolouring
   with the eight civilisation copies, the TER257 row rule with DGROUP:1A3E taken as 0 (recorded),
   the copies (D4DC from 6E92, the TER257 copies), the page-2 art rectangle of step 4, and an
   accessor by family and DOS index (`pdos_shape`). D's shapes D4CE, D294, D2D4, 6DFE, B886, B880, B27A, B29A, 7EEC, 6E96 are
   families; only tables below DGROUP:6B30h (1946, 1956, ...) stay in OFFSETS.md. The cut rules
   were verified against `build/dos/disasm/ovl05.lst` O5:1455..1AF5 and by a scratch simulation.
   Test plan E.13.7.
2. **RV1-6: no activation during a run.** "Locate DOS files..." only records the choice (phase R's
   browse, `civ64.cfg` `dos_data`); the store is built once, before the emulation (E.3.6, E.4.2).
3. **RV1-8: the message cadence is area A's** (one message per run, then beeps); E supplies its
   sentence alone, and A appends the Locate hint (E.4.3 corrected).
4. **E.18-1..5 resolved** (E.18 now records the resolutions): a DOS folder is refused only when it
   is the data directory itself; `CIV_UNP.EXE` stays reachable headless only; Asan deferred;
   eager checking accepted; immediates are constants. OPEN P28 is settled here (E.16).
5. **Corrected D0 facts adopted:** FORMATS 6 (data tables, constants, run-time storage) seeds the
   registry, so DGROUP:1946/1956 are **8 words** each and DGROUP:1882/18E4 **49 words** each
   (E.10.3); FORMATS 4: the pointer shapes are only the torch and the GO arrow (E.9.5); FORMATS
   1.3 item 5: DGROUP:68F8 starts at 0 and persists across pictures (E.6.2); pictures keep `w`
   columns per row (X1 odd width: only `TORCH.PIC`, E.6.1).
6. Smaller: RV1-5 (every DOS variation passes `--dos-data`, E.13.6), RV1-7 (the pointer leaves E
   as palette indices, area A converts, E.9.5), RV1-11 (`obs_init` after E's activation, E.3.3),
   RV1-18 (A's `pdos_profile.c`, E.2.1).

## E.0 Authority relied on

| Point | Source | Effect here |
|---|---|---|
| The DOS source comes from phase R: `--dos-data`, `CivDos.zip`/`Civ-Dos.zip`/`Civ_Dos.zip`, a `CivDos` folder, `dos_data`, the player's choice; a DOS ZIP is read into memory and never extracted | DESIGN.md 12.3; STATUS "Extension track" phase R (user's requirements of 2026-10-10 16:40); ext-X0-acceptance D8 ("R supersedes 5.9/5.11 `--dos-data` ... no default") | 5.9's "`--dos-data` names it, there is no default" is superseded; the store reads whatever R found |
| DOS instruction immediates may be C constants with their DOS address; data-segment tables, pictures, palettes, fonts and texts are read at run time | ext-X0-acceptance D6 (user decision, 2026-10-10 17:45); ext-d1-decisions E.18-5 | 5.9's "sprite rectangles, layouts ... read from the DOS image" applies to data tables; immediates (the cut rectangles of O5:1455 are loop arithmetic) are constants (E.9, E.10) |
| Asan builds and tests run once at the end of the queue | STATUS "User directions" 2026-10-10 21:20; ext-d1-decisions K8, E.18-3 | D2's gate "7.6 passes under Asan" becomes "7.6 passes in Checked and Release; the Asan run of the same test is part of the final Asan run" (E.18 item 3) |
| E owns the shape cut O5:1455; Locate records only; A's message cadence | ext-d1-decisions RV1-1, RV1-6, RV1-8, RV1-16 | E.9, E.3.5, E.4.3 |
| `stretch` removed, screen follows the client, M in the backlog | DESIGN.md 12.4; STATUS | no effect on this area |

## E.1 Summary of the design

* **One read-only host service** (`host_dos_read`, `host_dos_where` in `host.h`) hides whether the
  DOS source is a folder or an in-memory ZIP. Both back ends implement it; the ZIP member lookup
  uses `res/zip.c`.
* **One activation** (`pdos_assets_open`) reads every pinned file once, checks its size and SHA-256,
  unpacks `CIV.EXE`, checks the unpacked image against pinned derived hashes, validates every
  registered data table, parses the fonts and texts, decodes every picture and palette and
  reproduces the DOS start-up shape cut O5:1455 (map, icon, unit and pointer shapes). It runs once,
  before the emulation starts, and never during a run ("Locate DOS files..." takes effect at the
  next start). Afterwards the store is immutable, allocation-free and fault-free.
* **Pins** live in `tests/dos-files.txt` (names, sizes, SHA-256, use class; no bytes), turned into a
  generated C table at build time.
* **Decoders** (`present/dos/pdos_exe.c`, `pdos_pic.c`, `pdos_font.c`, `pdos_text.c`) follow the DOS
  routines of FORMATS 1..4 and EXECUTABLE 2, mirror the Python viewers in `gen/dos/`, and refuse
  only inputs whose DOS result would depend on stale memory or overrun a DOS buffer. None of those
  occurs in the pinned files (scratch).
* **Data tables** are read only through an **offset registry** (`docs/dos/OFFSETS.md`, generated
  into C), never by raw address; only initialised data (below DGROUP:6B30h, the far data segments,
  the driver's data) can be registered. Shape handles and other run-time storage are not tables:
  the shapes come from `pdos_shapes`.
* **Shapes** (`pdos_shapes`): the cut O5:1455 reproduced from the decoded pictures, rectangles as
  constants with their O5 addresses (user D6), recolouring from the registered colour tables;
  renderers ask by family and index (`pdos_shape(PDOS_SH_ICON, 64 + 32 * civ + type)`).
* **Failure** (5.9): with an explicit `--graphics dos`, exit code 2 with one sentence naming the
  file; otherwise the DOS profile is unavailable for the run and the Windows profile continues;
  area A shows the sentence once per run.
* **P8 settled**: nothing in the DOS source is ever written; the section-file lookup is the DOS
  routine run read-only, without its cache write.

## E.2 Modules and build

### E.2.1 Files

| File | Role |
|---|---|
| `present/dos/pdos_assets.h/.c` | The store: activation, status and message, file ids, accessors for pictures, palettes, fonts, texts and tables; includes `pdos_shapes.h`. The only E header renderers include. |
| `present/dos/pdos_shapes.h/.c` | The shape cut O5:1455 (E.9): cut table, page-1 work buffer, recolouring, families, `pdos_shape`, `pdos_page2_initial`. |
| `present/dos/pdos_exe.h/.c` | MZ headers, the EXEPACK decoder, the overlay directory, the address spaces `R:`, `O<n>:`, `G:` and the relocation lookup. |
| `present/dos/pdos_pic.h/.c` | `*.PIC` and `*.PAL`: word reader, chunk walk, LZW, RLE, X0/X1 rows. |
| `present/dos/pdos_font.h/.c` | `FONTS.CV`: layout, glyph rows, the model functions of `G#4` and `G#12`. |
| `present/dos/pdos_text.h/.c` | Line files and section files (the read-only DOS lookup). |
| `present/dos/pdos_tables.h/.c` | Registered data tables: resolution, validation, typed reads. |
| `present/dos/pdos_registry.h/.c` | **Generated** by `gen/dos/registry.py gen` from `tests/dos-files.txt` and `docs/dos/OFFSETS.md`: file ids, pins, derived hashes, table descriptors. |
| `res/zip.h/.c` | Gains `zip_find_base` (moved from `civ64_locate.c` `find_exe`, 303..320): the one entry whose last component equals a name ignoring ASCII case, and its folder prefix. |
| `platform/w16/host.h` | Two declarations and one enum (E.3.1). |
| `platform/win32/host_win32.c/.h` | `hw_set_dos_source`, `host_dos_read`, `host_dos_where`; `hw_find_name` (moved from `civ64_locate.c` `find_name`, 134..158, which then calls it). |
| `tests/headless/host_headless.c/.h` | `hh_set_dos_source`, `hh_dos_inject`, `host_dos_read`, `host_dos_where`. |
| `tests/headless/harness_main.c`, `harness.c` | `--dos-data PATH`, `--dos-inject NAME:KIND`; activation in `hh_run` before `vm_init` (E.3.4). |
| `win64/civ64_main.c`, `civ64_start.c` | The call site of activation and the data-directory rule (E.3.3). |
| `gen/dos/registry.py` | `pins`, `gen`, `goldens`, `check` (E.4, E.10, E.13). |
| `gen/dos/shapes.py` | An independent Python model of O5:1455 written from SPRITES 2..6 (reusing `pic.py`): `goldens` for E.13.7, `view` for contact sheets under `build/dos/view/` (never in the repository). |
| `gen/dos/nodos.py` | The D-1 check that no DOS bytes are in the repository or the binaries (E.13.5). |
| `tests/dos-files.txt`, `tests/dos-decoded.txt` | Pins and decoded-content goldens: hashes, sizes, names only. |
| `docs/dos/OFFSETS.md` | The offset registry (E.10). |
| `tests/test_dos.c` | The 7.6 test program (E.13). |

**Choice (prefix):** every `present/dos` symbol starts with `pdos_` / `Pdos` / `PDOS_`. `dos_` is
taken by the virtual DOS (`platform/w16/dos.h`: `dos_init`, `dos_canonical`, ...) and all portable
objects share one link; build.cmd also names objects by base name (`%%~nf.obj`, line 71), so file
names must be unique across `platform/w16`, `present`, `present/dos`, `res`, `rt`, `core`.
Alternative: `dos_` with a rename of w16's functions (touches w16: rejected). Areas B, C and D
should use the same prefix for their `present/dos` modules (merge note); area A's profile module
is `present/dos/pdos_profile.c` (RV1-18), D's map modules use `present/map/pmap_*.c` (RV1-3).

### E.2.2 Language and build

* Portable C under DESIGN.md 1: only `<stdint.h>`, `<stddef.h>`, `<string.h>`, `<limits.h>`; no
  VLAs; `static inline`; layout checks by the typedef idiom. Includes: `host.h`, `sha256.h`
  (platform/w16, a utility, not a `w16_` API), `frame.h` where needed, and their own headers. No
  `vm.h`, `w16_int.h`, `w16_api.h`, `user.h`, `queue.h`, `clock.h`, core or rt header (checked by
  `registry.py check`, E.13.4). No `#if CIV_CHECKED` anywhere in E's modules (O1: present/ behaves
  the same in every variant).
* **build.cmd**: line 68 gains `"%PORT%\present\dos\*.c"` in the portable loop, so the three
  language checks (c11, c17, the C99 parse at line 83) cover E; no new `/I` (E's files include
  their neighbours by name and `host.h`/`sha256.h`/`zip.h` through the existing `/I`). After the
  generator loop (line 42..49): `python -B gen\dos\registry.py gen` (deterministic; a malformed
  `tests/dos-files.txt` or `OFFSETS.md` fails the build with `BUILD_ERROR=gen\dos\registry.py`).
  `win64/civ64_locate.c` keeps compiling in the Win32 loop (148); it now calls `hw_find_name` and
  `zip_find_base`.
* **test.cmd**: after the `gamedata` precheck (line 20): `build\dosdata\CIV.EXE` must exist, else
  `TEST_ERROR=build\dosdata missing` (the 7.6 tests need it, as the base tests need `gamedata`).
  `test_dos.exe` runs in the generic loop (line 40) with the common arguments; it finds the DOS copy
  as the sibling `<gamedata>\..\dosdata`. Two new lines: `registry.py check` (REGISTRY_OK) and
  `nodos.py check` (NODOS_OK).

## E.3 The DOS source and the host service

### E.3.1 host.h (extension 5.1 "a read-only service for files of the DOS directory")

Added after the fonts section:

> **C passage condensed for the public copy.** The original record has here a block of 12 lines of C declarations: functions `host_dos_read`, `host_dos_where`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* Results: `HOST_DOS_NONE` no DOS source; `HOST_DOS_MISSING` no such file (a directory of that name
  counts as missing); `HOST_DOS_SIZE` its size differs; `HOST_DOS_ERROR` unreadable, or a ZIP entry
  that fails its CRC-32.
* No core, rt or w16 function calls them (no w16 call site changes; E.14).
* **Choice:** one whole-file read with a caller-sized buffer. The pinned size bounds every
  allocation before any byte is read. Alternatives: a stream API (`open/read/close`: more state,
  no benefit for files read once); the back end returning the ZIP bytes and portable ZIP handling
  in `present/dos` (two code paths in E; the host already owns the source).

### E.3.2 Back ends

* **Win32** (`host_win32.c`, new functions after `host_dir_list`, 434..469):
  * `int hw_set_dos_source(const wchar_t *from, const uint8_t *zip, uint32_t zip_size)`: `from` is
    `g_found.dos_from` (an absolute folder, or the ZIP's path); with `zip` set it opens a static
    `ZipArchive` over the borrowed bytes (`zip_open`; R already validated them) and finds the prefix
    with `zip_find_base(z, "civ.exe")`; 0, or -1 (then no source). Records `host_dos_where()` in
    Windows-1252.
  * `host_dos_read`, folder: `hw_find_name(dir, name, 0, path)` (ASCII case ignored; of several the
    ordinal smallest; files only; as R's lookup), `CreateFileW(GENERIC_READ, FILE_SHARE_READ,
    OPEN_EXISTING, FILE_FLAG_SEQUENTIAL_SCAN)`, `GetFileSizeEx` equal to `size` (else
    `HOST_DOS_SIZE`), `ReadFile` exactly `size`, `CloseHandle`. Never `GENERIC_WRITE`,
    `FILE_WRITE_ATTRIBUTES`, `DELETE`, `CREATE_*`, `SetFileTime` or `SetFileAttributes`.
  * `host_dos_read`, ZIP: `zip_find(z, prefix + name)`; `usize == size` (else `HOST_DOS_SIZE`);
    `zip_extract` into `buf` (inflate, exact size, CRC-32; failure `HOST_DOS_ERROR`).
* **Headless** (`host_headless.c`, after `host_dir_list`, 264..271):
  * `void hh_set_dos_source(const char *path)`: a folder, or a file ending in `.zip` (read whole with
    `hh_read_file`, `zip_open`, `zip_find_base`); NULL: none.
  * `host_dos_read`, folder: `_open(path, _O_RDONLY | _O_BINARY)` (the test host is NTFS, case
    insensitive), `_filelength == size`, `_read` loop; ZIP: as Win32.
  * `void hh_dos_inject(const char *name, int kind)`: tests only; for that name the next reads report
    `HOST_DOS_MISSING`, `_SIZE`, `_ERROR`, or flip one byte after a successful read (kind
    `HH_DOS_FLIP`, which the SHA-256 check then catches). **Choice:** injection instead of broken
    copies of DOS files (no extra copies under `build/`, deterministic). Alternative: broken copies
    under `build/run/<run-id>/` (allowed by 2.1, more file churn).

### E.3.3 civ64 start-up (`win64/civ64_main.c`)

The order, with the current line numbers of `civ64_main.c`:

1. `civ64_locate` (194) as now; `civ64_open_data` and the other checks (199..207) as now.
2. **New, after 207:** if `g_found.dos_src != CIV64_SRC_NONE`: the data-directory rule (below), then
   `hw_set_dos_source(g_found.dos_from, g_found.dos_zip, g_found.dos_zip_size)`.
3. **New:** `st = pdos_assets_open()`. With an explicit `--graphics dos` (option added in D3, area A)
   and `st != PDOS_OK`: `fail(pdos_assets_message())`, which shows one message box and exits with
   code 2 (`fail`, 59..63). Otherwise the result is kept for the whole run; the profile switch
   (area A) asks `pdos_assets_status()` and, under A's cadence, shows `pdos_assets_message()`
   (E.4.3).
4. Then the options (208..226), the window (228..239), `vm_init` (240) as now; area A's
   `obs_init()` comes later, before `civ64_run_game` (261), so after E's activation (RV1-11).

So activation finishes before the window exists and before the emulation's clock, memory or queue
are touched (E.14). `pdos_assets_open` has exactly this one call site in civ64.

**The data-directory rule (5.9: "must not be the data directory or lie inside it").** Function
`civ64_dos_dir_ok(dos_dir, data_dir, err, n)` in `civ64_start.c`, folder sources only: both paths go
through `CreateFileW(FILE_FLAG_BACKUP_SEMANTICS)` + `GetFinalPathNameByHandleW` (as
`civ64_open_data` does, 195..215) and are compared with `CompareStringOrdinal(..., TRUE)`.

* **Equal**: refused as an invalid R candidate, exit code 2, "The DOS folder %s is the game's data
  directory; keep Civilization for DOS in its own folder." This cannot happen with the pinned files
  except in a case-sensitive folder holding both `civ.exe` and `CIV.EXE` (`civ64_open_data` opens
  `civ.exe` by exact name, R's `check_dir` takes the ordinal smallest match), where the core would
  otherwise list DOS files as its own (`host_dir_list`).
* **Inside** (for example the user's layout: program folder as data directory, R step 4a, with a
  `CivDos` subfolder, R step 3): **accepted** (ext-d1-decisions E.18-1) and recorded in FIDELITY,
  because the core cannot see it: the virtual DOS resolves only `\CIV\NAME`, depth exactly 2
  (`platform/w16/dos.c` `resolve`, 173..186), and `host_dir_list` lists regular files of the top
  level only (`host_win32.c` 462). Test: E.13.3.

### E.3.4 Harness (`tests/headless`)

* `--dos-data PATH` (folder or ZIP) in `harness_main.c` (beside `--host-size`, 432) and
  `--dos-inject NAME:missing|size|error|flip` (repeatable).
* In `hh_run` (harness.c), after `run.log` is opened (1045..1046) and **before `vm_init` (1061)**:
  `hh_set_dos_source(o->dos_data)`, `pdos_assets_open()`, then the result goes to
  `<out>/dos-assets.log` ("dos_assets status N files F decoded D message ..."). Nothing goes to
  `run.log`, `events.log`, `presented.log` or the summary line, which G-1 and the P0 runner compare
  (`tests/harness/ext_g1.py`). The DOS source is `build/dosdata` itself (read-only, 2.1 "Every run
  and test uses that copy").
* `pdos_assets_close()` after the run (frees; leak-neutral).

### E.3.5 Never writing the DOS files (OPEN P8, settled)

* No host function can write the DOS source: `host_dos_read` is its only access, opened read-only.
* The section lookup (E.8.2) is the DOS routine R:1F4D:01AD without its step 6 (the `r+b` cache
  write, FORMATS 3.3). The cached index is read, never updated; DOS-written stale slots only cost
  the DOS program a re-scan and give the same text (FORMATS 3.4), and the possible "index full"
  hang (FORMATS Open 3, OPEN X6) is bounded in the port (256 probes, then the scan; E.8.2).
* `REPLAY.TXT` (FORMATS 3.1) is never created (DOS-PROFILE 3.3: the core's own save dialog).
* Proof: `build/dosdata` files carry the read-only attribute (ext-X0-acceptance), so any write
  access request fails in every test run; `test_dos` compares each file's size, SHA-256 and
  modification time before and after; the session's section-10 hash check of `C:\Projects\Civ1RE\dos`
  covers the originals.
* **Open (host fact):** a read can update the file's last-access time if the volume keeps it (an
  NTFS policy). It cannot be prevented with a read-only handle (`SetFileTime(-1)` needs
  `FILE_WRITE_ATTRIBUTES`). Section 10 compares attributes and `LastWriteTimeUtc` only. Record in
  FIDELITY.

### E.3.6 "Locate DOS files..." during a run (RV1-6)

* The store is built once per process, before the emulation (E.3.3, E.3.4). Nothing activates,
  replaces or closes it while the game runs, so the pointers renderers hold (pictures, shapes,
  tables) stay valid for the whole run, and a profile that was unavailable at the start stays
  unavailable until the next start (O6 and T2: a profile that could appear mid-run would not have
  been kept current from the run's events).
* Area A's system-menu item "Locate DOS files..." (and the hint in A's refusal message) runs phase
  R's browse dialog (12.3) and its validity check, and on success only stores the choice in
  `civ64.cfg` `dos_data` as phase R does for a chosen location; its confirmation says that the DOS profile becomes
  available at the next start. It calls no `pdos_` function and no `hw_set_dos_source`.
* `pdos_assets_open` "closes a previous store first" only for `test_dos` and the harness, which
  call it between runs, never while a run's renderers hold pointers (E.13.1 item 12).
* Test: E.13.3 (A's Locate handler leaves `pdos_assets_status()` and the store's addresses
  unchanged; it is A's function, tested by A with E's status call).

## E.4 Pinning and activation

### E.4.1 `tests/dos-files.txt`

One line per file: `<sha256> <size> <use> <NAME>`, `#` comments. Written once by
`gen/dos/registry.py pins` from `docs/dos/dos-hashes.txt` (hashes) and `build/dosdata` (sizes);
`registry.py check` re-verifies both. Use classes:

| Use | Files (v1) | Meaning |
|---|---|---|
| `req` | `CIV.EXE`, `MGRAPHIC.EXE`, `FONTS.CV`, the 106 `*.PIC`, the 38 `*.PAL`, the 11 texts `CREDITS`, `STORY`, `KING`, `HELP`, `ERROR`, `PRODUCE`, `BLURB0..4` (158 files, 1,918,109 bytes, scratch) | verified at activation; missing or different: the profile is unavailable |
| `opt` | `CIV_UNP.EXE` | read only when `CIV.EXE` is absent (E.5.3) |
| `der` | `CIV.EXE#root` (203,584 bytes), `CIV.EXE#reloc` (10,100 bytes) | not files: the SHA-256 of the unpacked load module and of its 2,525 relocations as (offset, segment) word pairs in table order, both taken from `CIV_UNP.EXE` (load module 10,128..213,711; relocation table at its `e_lfarlc`) |

Not listed, never read: `EGRAPHIC.EXE`, `TGRAPHIC.EXE`, `MISC.EXE`, `UNP.EXE`, the five `*.CVL`,
`INTRO.TXT` (the text-mode set-up screen, a DOS-only scene the profile omits), `INTRO3.TXT` (read by
nothing, FORMATS 3.1), `READ.ME`, `CIVIL0/1.MAP/.SVE`, `FAME.DTA` (DOS's own hall of fame; the core
supplies its own).

**Choice (required set):** the files the profile can display or read data from, decided per file
type, pruned at D8 to the files some renderer opens (a test lists the ids opened by D4..D7).
Alternatives: all 176 files (a missing sound driver would disable the graphics profile); only files
opened so far (D2 has no renderers yet). `MGRAPHIC.EXE` is required for the default palette table
(E.10, OPEN P4 reference for area B); if B does not use it, it moves to "not listed" (Open E3).

`registry.py gen` turns the list into `pdos_registry.c`:

> **C passage condensed for the public copy.** The original record has here a block of 10 lines of C declarations: types `PdosPin`, `PdosFileId`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

The ids give renderers compile-time names; names built at run time by the DOS logic (`birth%d.pic`,
`king%02d.pal`, `back%d%c.pal`, `govt%d%c.pic`, `iconpg%c.pic`) go through `pdos_file_id(name)`
(ASCII case ignored; -1 and a presentation diagnostic for an unknown name). `CIV64_DOS_EXE_SHA256`
in `civ64_locate.h` (45..47) is a second copy of one pin; `registry.py check` compares them.

**Choice (one source of truth):** the text file is the source, the C table is generated at every
build. Alternatives: a hand-written C table checked against the text file (two copies to keep in
step); reading the text file at run time (civ64 must not depend on repository files).

### E.4.2 Activation: `pdos_assets_open`

> **C passage condensed for the public copy.** The original record has here a block of 8 lines of C declarations: types `PdosStatus`; functions `pdos_assets_open`, `pdos_assets_status`, `pdos_assets_message`, `pdos_assets_close`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

Sequence (all or nothing; the first failure frees everything and is the result):

1. `host_dos_where()` empty: `PDOS_E_NONE`.
2. Each `req` file in list order: `host_alloc(size)`, `host_dos_read`, SHA-256 against the pin
   (`sha256_hex`). `CIV.EXE` first; if it is missing, `CIV_UNP.EXE` is tried (E.5.3).
3. Program image (E.5): EXEPACK, derived hashes, overlay directory.
4. Registry (E.10): every table resolved and validated.
5. `FONTS.CV` (E.7), the texts (E.8).
6. Every picture and palette decoded (E.6); each raw `*.PIC`/`*.PAL` buffer is freed after its
   decode (**Choice**: keep only decoded data; alternative: keep raw bytes for a lazy re-decode).
7. Shapes (E.9): the cut O5:1455 on the decoded `SP299.PIC`, `TER257.PIC`, `SP257.PIC` and
   `TORCH.PIC`, with the colour tables of step 4; the 64,000-byte page-1 work buffer is freed
   afterwards. A failure here is a defect (the pictures are pinned): `PDOS_E_FORMAT`, reason
   "shape cut".
8. Status `PDOS_OK`. From here no function of the store allocates, frees, reads a file or a clock,
   and nothing reopens the store while the run lasts (E.3.6).

**Choice (when files are checked):** all at activation, before the emulation starts. Rationale:
every profile is current at all times (O6, T2), so a hidden DOS profile may need any file at the
next tick and a switch must never fail mid-scene; an explicit `--graphics dos` must fail before the
game starts, not mid-game; one immutable, hash-verified copy in memory removes the gap between
check and use; and under `--timing host` no decode can take virtual time inside a presentation tick
(T6). This reads 5.9's "checked the first time it is needed" as "before the profile can first need
it" (accepted, ext-d1-decisions E.18-4). Alternatives: lazy check and decode per file at first use (mid-game failures,
exit 2 mid-game, tick stalls); eager check with lazy decode (keeps the tick-time cost under host
timing).

### E.4.3 Failure behaviour (5.9)

Messages (Windows-1252, one sentence, the first failing file in list order, `%s` the source). E's
sentence stands alone: it carries no prefix such as "DOS graphics are not available:" and no
instructions; area A shows it as it is and appends its own Locate hint (RV1-8).

| Status | Message |
|---|---|
| `PDOS_E_NONE` | "Civilization for DOS was not found (CivDos.zip, Civ-Dos.zip, Civ_Dos.zip or a CivDos folder next to civ64.exe, or --dos-data)." |
| `PDOS_E_MISSING` | "The DOS graphics profile needs FONTS.CV, which %s does not hold." |
| `PDOS_E_SIZE`, `PDOS_E_HASH` | "FONTS.CV in %s is not the file civ64 knows (its size or SHA-256 differs)." |
| `PDOS_E_READ` | "FONTS.CV in %s cannot be read." |
| `PDOS_E_FORMAT` | "FONTS.CV in %s cannot be decoded (%reason)." (only a decoder defect: the file is pinned) |
| `PDOS_E_REGISTRY` | "CIV.EXE in %s does not hold the data table %id (%reason)." (a registry defect) |

* Explicit `--graphics dos` (5.9): civ64 exits with code 2 after this message (E.3.3 step 3); the
  harness exits 2 with `HARNESS_ERROR` and the message.
* Otherwise: the Windows profile runs; the store stays empty for the run; civ64 never exits for it.
  The cadence is area A's (RV1-8, 5.9 "one port-level message"): the first refused switch of the
  run shows `pdos_assets_message()` alone, followed by A's hint ("Locate DOS files..." in the
  system menu, effective at the next start, E.3.6), through `host_message`; later refusals in the
  same run only beep. What a remembered `dos` profile does at start is A's (K7).
* R already refused a present but invalid DOS candidate (a damaged ZIP, a different `CIV.EXE`) with
  exit code 2 (12.3); the store's failures concern the other files.

## E.5 The program image

### E.5.1 MZ headers (`pdos_exe.c`, mirrors `gen/dos/dosexe.py` `parse_mz`)

`int pdos_mz_parse(const uint8_t *p, uint32_t n, uint32_t base, PdosMz *out)`:

* `MZ` or `ZM`; `e_cblp < 512`; `e_cp >= 1`; image end = `e_cp*512 - (e_cblp ? 512 - e_cblp : 0)`
  in 32-bit arithmetic; header bytes = `e_cparhdr*16 <= image end`; `base + image end <= n`;
  relocation table `[e_lfarlc, e_lfarlc + 4*e_crlc)` inside the header. Any breach:
  `PDOS_D_MZ`.
* Output: header size, image end, CS:IP, SS:SP, the overlay-number word (offset 1Ah), relocation
  count and table offset.

### E.5.2 EXEPACK (EXECUTABLE 2; DOS file)

`int pdos_exepack(const uint8_t *exe, uint32_t n, PdosRoot *out)`, the stub's algorithm on one
buffer, in place:

1. MZ of `CIV.EXE` with no header relocations; load module `lm` of length `L`.
2. EXEPACK header at `H = CS*16` (`H + 16 <= L`), IP = 0010h (the stub follows the 16-byte header),
   words: real IP, real CS, mem_start, exepack_size, real SP, real SS, dest_len, signature `RB`
   (4252h; a format constant of the stub, as `MZ`). `exepack_size == L - H`.
3. `D = dest_len*16` with `H <= D <= A0000h` (640 KiB, the conventional-memory limit), checked
   before `host_alloc(D)`. Copy `lm[0..H)` to `dst`.
4. Read cursor `s = H - 1`, skipping trailing FFh bytes; write cursor `d = D - 1`. Command loop (at
   most `H/3 + 1` commands): need `s >= 2`; command byte `dst[s]`, count = word at `s-2`; `s -= 3`.
   * `B0`/`B1` fill: value byte `dst[s]`, `s -= 1`; need `count <= d + 1` and `d - count >= s` (the
     unread packed bytes are never overwritten); `memset`.
   * `B2`/`B3` copy: need `count <= s + 1`, `count <= d + 1`, `d >= s`; `memmove` (the regions may
     overlap with the destination above the source).
   * any other: `PDOS_D_EXEPACK`. Bit 0 set: last command.
   The untouched prefix `dst[0..s]` stays (in place). Scratch: 437 commands (221 fill, 216 copy),
   13 padding bytes, the invariant held with a smallest margin of 0 at a fill and 254 at a copy,
   and the loop ends with `s == d == 160`; the in-place result equals `CIV_UNP.EXE`'s load module.
5. Packed relocations at `H + 293` (16-byte header, 255 bytes of stub code, the 22-byte message:
   **DOS file**, scratch), 16 groups of a count word and that many offset words, group g giving
   segment `g*1000h`; each linear address + 2 <= `D`; the table must end exactly at `L`.
6. Output: root (`D` bytes, owned), relocations (2,525 (offset, segment) pairs in table order,
   owned), real CS:IP, SS:SP. Then the SHA-256 of the root and of the pairs must equal the `der`
   pins (else `PDOS_E_FORMAT`): every run proves the unpacked image is `CIV_UNP.EXE`'s.

**Choice:** in place on one buffer, as the stub (equivalent to the Python decoder's two buffers
because the invariant is checked). **Choice:** the relocation table at the recorded offset 293,
validated by its exact end and the derived hash. Alternatives: find the stub's message text
(would put a DOS string into the binary, 2.3); try every start that ends exactly at `L`
(ambiguous in general).

### E.5.3 `CIV_UNP.EXE` (5.9 "accepted instead")

When `CIV.EXE` is missing and `CIV_UNP.EXE` matches its pin: root = its load module, relocations =
its header table, overlays = its tail; the same derived-hash check. When `CIV.EXE` is present,
`CIV_UNP.EXE` is not read (**Choice**; alternatives: prefer `CIV_UNP.EXE`, or compare both at
run time; the decoder path must work for users without the unpacked copy, which is not part of the
release). Phase R currently refuses a DOS source without `CIV.EXE` (12.3 "Validity"), so this
path is reachable only headless (ext-d1-decisions E.18-2: phase R unchanged).

### E.5.4 Overlays and address spaces

* Overlay directory (EXECUTABLE 6.1; DOS file): from the root's image end, skip zero bytes, parse an
  MZ header, take its load module; exactly 23, overlay-number words 1..23 in order, the last ending
  exactly at the end of the file (scratch: 225 zero bytes before the first at 178,176, gaps of 6..470
  bytes between, the last ending at 305,030). Overlay images point into the kept `CIV.EXE` bytes
  (no copy). Overlay relocations are parsed but not needed (all against R:2374, EXECUTABLE 6.2).
* `MGRAPHIC.EXE`: MZ header 512 bytes, load module 6,630 bytes, three relocations (scratch);
  `G:0000:oooo` is its load-module offset (EXECUTABLE 3).
* Address spaces (EXECUTABLE 3): `R:ssss:oooo` = root linear `ssss*16 + oooo`; `DGROUP:oooo` =
  `R:2B01:oooo` (`PDOS_DGROUP_SEG 0x2B01`, an immediate: EXECUTABLE 4, 5); `O<n>:oooo` = offset in
  overlay n; `G:0000:oooo`. Only `pdos_tables.c` resolves addresses (`static const uint8_t
  *pdos_image_at(int space, int ovl, uint16_t seg, uint16_t off, uint32_t len)`: NULL when
  `[addr, addr+len)` leaves the space).
* **Initialised extent:** DGROUP's bytes in the file end at DGROUP:6B30 (27,440 bytes; the root's
  load module ends there, scratch). Addresses at or above it are run-time data (for example
  DGROUP:6B34, PALETTE 2.6) and cannot be registered.
* `int pdos_image_is_reloc(uint32_t linear)`: binary search in the sorted relocation addresses. A
  relocated word holds a load-module segment (the `R:` notation's own value): scratch, DGROUP:6420,
  640A, 6444 are relocated and hold 271E, 26FA, 2767, the far data segments of EXECUTABLE 4.

## E.6 Pictures and palettes (FORMATS 1; DOS listing R:0000:108E..13C5, R:1FA1:05E0/0644)

### E.6.1 Output

> **C passage condensed for the public copy.** The original record has here a block of 10 lines of C declarations: types `PdosPic`; functions `pdos_pic`, `pdos_pal_dac`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* `m0` keeps both readers' views: `G#28` (G:0000:0162/01A1) sends `last - first + 1` triplets from
  data offset 2 to DAC entries `first..` (`pdos_pal_dac`); the fade target R:0000:04AA takes 768
  bytes from offset 6 of the stored chunk regardless of first and last (PALETTE 2.3, Open 8). Equal
  for every pinned file (first 0, last 255).
* Values stay 6-bit as stored (maximum 63 in every file, FORMATS 1.2). The 6-to-8-bit rule is area
  B's (5.9 "Palette"; FORMATS 1.4 "6-bit values"; OPEN P23).
* Rows hold exactly `w` pixels, as `pic.py` (`Decoder.row`) returns them. The only X1 picture of
  odd width is `TORCH.PIC` (scratch), whose 14th nibble per row R:0000:12FE stores but the only
  loader of that file, R:1FA1:044C, never uses (G#34 takes `width` bytes, DRIVER G#34, G#35). The
  198th byte that `G#19` copies per row of the X0 pictures `SLAG2`/`SLAM2` is stale row-buffer
  content (FORMATS 1.4, Open 5; OPEN P27, O7): drawing it or not is a renderer decision (area B,
  D4/D7); E supplies the 197 real columns. **Choice**; alternative: an X1 stride of
  `2 * ((w + 1) / 2)` (no user needs it).

### E.6.2 Algorithm and its DOS addresses

| Step | DOS | Port (`pdos_pic_decode(const uint8_t *p, uint32_t n, PdosPic *out, uint8_t *px_buf)`) |
|---|---|---|
| Word reader | 512-byte buffer refilled at DB36h (R:1FA1:0644); a refill past the end keeps stale bytes; no end-of-file test (FORMATS 1.3 item 1) | Reads little-endian words from the file image. Every header word (tag, length, chunk data, width, height, the LZW start word) must lie wholly inside the file; only the code stream's last word may be half (an odd-sized file), read as that byte and 0, and no code may use bits of the missing byte (below). Anything else past the end is `PDOS_D_TRUNC` |
| Chunk walk | R:0000:109E..1135: a tag whose low byte is 58h ends the walk, its high byte's bit 0 = X1; else a length word and `length >> 1` data words; `M0` (304Dh) kept, others copied and passed to `G#28` (ignored by MGRAPHIC) | Same word arithmetic (an odd length leaves the next tag misaligned, as in DOS); `M0` kept, `E0` noted, unknown tags skipped. Refused: a second `M0` (pinned files have at most one; the DOS DAC result would be the union of both ranges), an `M0` shorter than `2 + 3*(last - first + 1)` or with `last < first` (DOS would read stale buffer bytes), an `M0` longer than 770 bytes (**Choice**: the size of the `m0` array and of every pinned `M0`; DOS copies any length), any chunk longer than 6,144 bytes (DOS copies it over the dictionary area DGROUP:BA06..D205, 2,048 three-byte entries, FORMATS 1.3 item 4, and beyond), no `X` tag before the end (DOS loops on stale words, FORMATS 1.6) |
| Image header | R:0000:1138..119F: length word unused, width, height | Width and height; both 0: palette only, stop. Refused (`PDOS_D_SIZE`): width 0 with a height (R:0000:12B0 stores a row count of 0, and the `dec`/`jne` at R:0000:12FF or 1309 then runs 65,536 bytes per row), height 0 with a width (DOS reads the start word and draws no rows; refused as no file has it, **Choice**, alternative an empty picture), width above 320 or height above 200 (no DOS check; the row buffer DGROUP:E17E would overrun) |
| LZW start | R:0000:1227..12A5: a word, low byte = maximum code width clamped to 11 (R:0000:125F), high byte = the first 8 code bits; reset: prefixes FFFFh, roots 0..255, width 9, mask 1FFh, next 100h | Same, including the clamp. A width byte below 9 resets after every code, as in DOS (well defined; **Choice**: mirrored, alternative refuse) |
| Code | R:0000:1318..13C5: LSB-first bit buffer; `c < next` (signed compare, R:0000:1369): string of c; `c >= next`: c is replaced by next (R:0000:136D) and the string is that of the previous code [68F8] followed by the previous string's first byte [68FA]; new entry next (prefix = [68F8], byte = this string's first byte); [68F8] = c; width grows when next exceeds the mask; reset (R:0000:1270) when the width exceeds the maximum, after which [68F8] keeps the old dictionary's code | Same arithmetic on fixed arrays `prefix[2048]`, `suffix[2048]`, an output stack of 2,049 bytes. `c > next` is decoded as `c == next`, as in DOS (well defined; never in the files: `pic.py` note `code_beyond_next`) |
| RLE | R:0000:12BC..12EB: a byte other than 90h is output and remembered; 90h 0 = a literal 90h; 90h n = the remembered byte now, with the count byte [68EC] = n - 1 then decremented, so n - 1 copies after the earlier one (n in all); for n = 1 the count wraps to FFh and the run gives 256 copies after the earlier one (R:0000:12DF..12E7) | Same, including the byte wrap (**Choice**: mirrored; never in the files, FORMATS 1.3 item 6) |
| Rows | R:1FA1:01A2 per row: R:0000:1208 with `width` (X0) or `(width + 1)/2` bytes (X1); state runs across rows | Same; an X1 row keeps its first `w` nibbles; output never exceeds `w * h` |

**Refusals where DOS depends on stale memory** (all `PDOS_D_LZW`; none occurs in the files):

* the first code after a start or a reset is not a root (< 100h): its string would come from
  [68F8], which is 0 at program start and otherwise the last code of the previous decode, possibly
  of another picture, and is never reset (FORMATS 1.3 item 5). Scratch: 622 first codes (106
  starts, 516 resets), all roots. With this rule the result never depends on [68F8], so the port
  needs no state across pictures and every picture decodes the same in any load order (FORMATS 1.3
  item 5 says the same of any decoder that starts each picture from any previous code).
* a string expansion that walks through entry 100h created right after a start or a reset (its
  prefix is a code of the previous dictionary). FORMATS 1.3 item 5: code 100h never occurs in
  1,019,502 codes; `pic.py check` finds no stale use.
* a code whose bits extend past the file's last byte. Scratch: no picture's codes use the padding
  byte of an odd-sized file's last word (59 of the 144 files have odd size).

With these, chains strictly decrease (every other prefix is a smaller index), so a chain is at
most 2,048 long; a longer one is still refused (`PDOS_D_LZW`, defence). Scratch: the longest string
is 61 bytes.

**Trailing bytes** after the last row are ignored, as in DOS (the X chunk's length word is unused).

**Choice (stale state):** refuse instead of modelling the DOS program's global decoder state across
pictures. Alternatives: model [68F8] and the dictionary across loads (makes decoding depend on load
order, against frame determinism); accept only bytes identical to the files' patterns (a max-width
byte of exactly 11, etc.: stricter than the routine).

### E.6.3 Mirror of `gen/dos/pic.py`

`WordReader` → the word reader; `Decoder.lzw_byte` → `lzw_byte`; `Decoder.row` → `rle_row`;
`decode` → `pdos_pic_decode`. Where the Python decoder records a note, the C decoder refuses
(`stale_entry_used`, and the first-code rule, which Python enforces only at a start) or mirrors
(`code_beyond_next`, `rle_count_1`); `pic.py check` proves all notes are zero for the 144 files, so
the outputs agree (tested, E.13.2).

## E.7 Fonts (`FONTS.CV`; FORMATS 2; DRIVER 1.7, 3.4)

> **C passage condensed for the public copy.** The original record has here a block of 12 lines of C declarations: types `PdosFont`; functions `pdos_font_count`, `pdos_font`, `pdos_font_row`, `pdos_font_advance`, `pdos_font_line_height`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* Parse (`fontcv.py parse`): count N with `1 <= N` and `2 + 2N <= size`; offsets P(n); header bytes
  P-8..P-1; `last >= first`; `bpr` 1 or 2 (others would mis-stride in DOS: `k << (bpr - 1)`;
  refused, `PDOS_D_FONT`); width table and bitmap `[P, P + stride*(height + extra))` inside the
  file. Pinned: 9 fonts tiling the file with one padding byte between fonts 4 and 5.
* `pdos_font_row`: the two bytes at `P + row*stride + i*bpr` as `first << 8 | second`
  (`xchg bl, bh`), bit 15 leftmost. For a one-byte-per-row font the second byte is the next glyph's
  (or the next row's, or the next font's) byte, exactly as in the driver's memory, which is the file
  in order (DRIVER 1.7); a byte past the end of the file reads 0 (cannot happen for the pinned file,
  whose last font has two bytes per row).
* `pdos_font_advance` mirrors G:0000:115D: 0 for `n == 0`, `n > N`, `code >= 80h`, or a code
  outside first..last; else `(fixed or widths[code - first]) + spacing` as a byte, sign-extended
  (`cbw`, G:0000:11AA). `pdos_font_line_height`: `height + extra` as a byte (G:0000:11CE..11D1);
  0 for an invalid n.
* Glyph drawing (opaque/transparent, colour bytes, clipping, columns past 16 blank) is area B's
  (FORMATS 2.3, OPEN P5); E provides the data and these two functions only.
* `byte7` (P-1) is kept but read by no routine found (FORMATS Open 7).

## E.8 Texts (FORMATS 3)

Raw bytes throughout: no CP437 or Windows-1252 translation, no token substitution, no line
breaking (**Choice**: those are drawing rules, area B / D7: `$` tokens R:1F4D:0471, `^` and wrapping
R:1F4D:0000/0088, colour bytes; FORMATS 3.5: `%` is drawn unchanged with font 5). Alternative: a
decoder that substitutes and wraps (would need core data at decode time).

### E.8.1 Line files (`CREDITS.TXT`, `STORY.TXT`)

The DOS reader is `fscanf(f, "%[^\n]\n", buf)` on an `"rt"` stream (FORMATS 3, MS C knowledge
**inferred** there). Port model (`texts.py` `text_mode`, `scan_lines`):

* text mode: CR immediately followed by LF becomes LF; a lone CR stays; the first 1Ah ends the
  stream;
* a record is the bytes up to the next LF (at least one byte; an empty match at the start ends);
  then all white space (space, tab, LF, VT, FF, CR) is skipped, so blank lines and the next line's
  leading blanks vanish;
* a record of 256 bytes or more is refused (`PDOS_D_TEXT`): the DOS buffer is 256 bytes and unbounded
  `%[` would overrun it. Pinned: longest 43 (`STORY`), 25 (`CREDITS`).

> **C passage condensed for the public copy.** The original record has here a block of 2 lines of C declarations: functions `pdos_text_count`, `pdos_text_line`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

`CREDITS` gives 24 records, `STORY` 52 (FORMATS 3.5). What the DOS program shows after the end of
the file (CREDITS keeps the previous buffer; STORY stops at -1, FORMATS 3.6) is the timeline's
business (area C); E only reports the count.

### E.8.2 Section files (`KING`, `HELP`, `ERROR`, `PRODUCE`, `BLURB0..4`)

The DOS lookup R:1F4D:01AD (FORMATS 3.3) is reproduced **read-only**, steps 1..5, without step 6:

1. hash h = (16-bit sum of signed `name[i] * i`) & FFh (R:1F4D:01C5..01EA);
2. probe the word at `2*(h + h/32)` (raw); above 1FFh and not 3030h: read one record in text mode
   from that offset; equal to the name: found; else h = (h + 1) & FFh and probe again;
3. an empty slot: scan records in text mode from 0200h, taking each record's file offset, until one
   equals the name or the stream ends (not found: -1);
4. text: skip further `*` records; append each record and one space until a record starting with
   `*`; the result is the number of text records and the joined bytes (the DOS buffer DGROUP:BA06).

At activation, for each section file, the scan of step 3 lists every `*` record; the lookup above
runs for each such name and its result (found offset, records, joined text) is kept. At run time
`pdos_text_section` only compares names:

> **C passage condensed for the public copy.** The original record has here a block of 3 lines of C declarations: functions `pdos_text_section`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* Equality with DOS: by construction the same routine; for the pinned files every name is found at
  its own line, and the twice-present name in `BLURB0` resolves to the first (FORMATS 3.4), which
  the kept result reflects.
* Bounds: files shorter than 0200h are refused (`PDOS_D_TEXT`); records as E.8.1; at most 256 probes
  (the DOS program would loop for ever on a full index, FORMATS 3.4), then the scan (**Choice**:
  scan; alternative: not found); a text with no `*` record after it is refused (the DOS loop would
  not end, FORMATS 3.6; every pinned file ends with an end marker).
* **Choice:** run the DOS lookup once per name at activation. Alternatives: ignore the index and map
  names from a scan (equal for the pinned files, proven only by test); run the lookup at each call
  (needs a text buffer at run time, against "allocation-free after activation").

## E.9 Shapes: the start-up cut O5:1455 (`pdos_shapes`; SPRITES 1..6; RV1-1, RV1-16)

### E.9.1 What the DOS program does and what the port reproduces

* **DOS.** O5:1455, called once at start-up from R:01A8:0810 (inside R:01A8:0486), loads pictures
  into page 1 and cuts rectangles with `G#2` GrabSprite into the sprite arena opened by `G#18`
  (O5:146F) and closed by `G#7` (O5:1AEB). Each shape's segment goes into a DGROUP word: DF62, B886,
  D294, D2D4, B27A, B29A, B2BA, 6DFE, 6E1E, D21C, 7EEC, D4CE, D4DE, 6E96, D4EE, D50E, B880, DF0C,
  D54E + 2(32c + j) (SPRITES 2..6). Nothing frees or re-cuts them (SPRITES 1). All of these words lie
  at DGROUP:6B30h or above, run-time storage that the file does not hold (FORMATS 6, 6.3), so they
  cannot be registry tables (E.10). The rectangles are immediates in O5:1455's loops (SPRITES 1
  "Data or code"; FORMATS 6.2).
* **Port.** `pdos_shapes_build` runs at activation step 7 (E.4.2) and repeats the procedure on a
  320x200 page-1 work buffer filled from the decoded pictures. The rectangles are C constants with
  their O5 address (user D6; ext-d1-decisions E.18-5; OPEN P28, settled in E.16). The
  civilisation colours come from the registered tables DGROUP:1946/1956 (E.10.3), which are data.
* **Path.** Only the 256-colour path (DGROUP:D762 not 0: steps 6 and 7 of SPRITES 2) is reproduced.
  The EGA step 6' is out of scope (prompt 5.9; SPRITES 5). Step 1, the disk prompt R:01A8:02A4, is a
  DOS-only scene (DOS-PROFILE 1.6). Step 7's copy of 48 bytes of `SP256.PAL` to DGROUP:6B34 is
  palette state (PALETTE 2.5, 2.6; area B), which E supplies as the decoded `SP256.PAL` `m0`.
* **DGROUP:1A3E is taken as 0** (RV1-16). Its file value is 0 (scratch); only R:01A8:00FC sets it,
  to 1, when the 256-colour flag is set and the largest free block is below 23BEh paragraphs
  (SPRITES 4; OPEN X10), a low-memory economy (inferred). The port models a machine with enough
  memory: terrain rows t 0..5 get all 16 mask variants. Rows t 6..9 (Tundra, Arctic, Swamp, Jungle)
  get only m = 0, and m 1..15 copy that handle (O5:1506..1518), so these terrains ignore their
  neighbours, as in DOS. Recorded in FIDELITY with the condition DOS would have used.
* **Arena.** `G#18` takes the largest free DOS block and `G#2` returns 0 when the arena is full
  (DRIVER G#2, G#18). The port models every grab succeeding: 524 grabs of at most 41x58 pixels
  (inferred: the case on any machine that had the memory for the 256-colour mode). Recorded.
* **Run sprites.** `G#2` stores each row without its leading and trailing zeros; `G#32`/`G#6` draw
  the stored pixels with inner zeros transparent (DRIVER 3.3; SPRITES 1). A full `w x h` array in
  which 0 is transparent therefore draws the same pixels; the port stores full arrays.
* **Page coordinates.** `G#2` takes absolute page coordinates; `G#3` and `G#20` add the port's origin.
  The page-1 port is DGROUP:19C2 (pointer DGROUP:19D4), page 1, origin (0, 0) in the file, with no
  direct writer of 19C4, 19C6 or 19D4 in the listings (scratch), so all rectangles below are page
  coordinates. R:1FA1:0254 draws each 320x200 picture at (0, 0) over the whole page (SPRITES 2).

### E.9.2 Interface (`pdos_shapes.h`, included by `pdos_assets.h`)

> **C passage condensed for the public copy.** The original record has here a block of 31 lines of C declarations: types `PdosShape`, `PdosShapeFamily`; functions `pdos_shape_count`, `pdos_shape`; constants `PDOS_POINTER_HOT_X`, `PDOS_POINTER_HOT_Y`, `PDOS_PAGE2_ART_X`, `PDOS_PAGE2_ART_Y`, `PDOS_PAGE2_ART_W`, `PDOS_PAGE2_ART_H`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* **Indices are the DOS indices**, so a renderer that follows the listing uses them unchanged:
  D's `D4CE[29]` is `pdos_shape(PDOS_SH_ICON, 29)`, its unit `D4CE[64 + 32 civ + type]` is
  `pdos_shape(PDOS_SH_ICON, 64 + 32 * civ + type)` (D4CE + 2 * 64 = D54E), its river `6DFE[mask + 16]`
  is `pdos_shape(PDOS_SH_RIVER, mask + 16)`. Draft D's requests (D 14, 17 "Area E") map as: D4CE
  ICON, D294 COAST, D2D4 MOUTH, 6DFE RIVER, B886 TERRAIN, B880 GRASS, B27A ROAD, B29A RAIL, 7EEC
  EDGE, 6E96 CITIZEN; 1946 and 1956 are registry tables (E.10.3).
* **NULL** for an entry the DOS program never fills: ICON 40..63 (D51E..D54C, "no writer found",
  SPRITES 6.3), ICON 64 + 32c + 28..31 (the unit loop cuts j 0..27), RIVER 0 and 16 (the loops start
  at i = 1). DOS holds 0 there, a null segment; no reader of these entries is known. The port draws
  nothing and counts a presentation diagnostic `dos_shape_uncut` (**Choice**; alternative: an empty
  shape without a diagnostic, which would hide a renderer defect). Out of range: NULL and
  `dos_shape_range`.
* **Empty cells are shapes.** ICON 0, 1 (SPRITES 6.3), 18 and 27 (the special-resource cells of
  Grassland and River, SPRITES 6.3) are cut and all zero: valid shapes that draw nothing (scratch:
  exactly these four).
* **Shared entries** return the same `PdosShape` (one pixel array): TERRAIN 16t + m equals 16t for t
  6..9, m 1..15 (O5:1506..1518); ICON 7 equals TORCH 0 (D4DC = [6E92], O5:1891..1894).
* **Page-2 art** is not cut (SPRITES 7): step 4 copies `SP299.PIC` (160, 50, 160x150) opaquely
  (`G#20`, DRIVER G#20) to the same coordinates of page 2, so a renderer reads those pixels from
  `pdos_pic(PDOS_F_SP299_PIC)` at identical coordinates inside `PDOS_PAGE2_ART_*`. Its own copy
  rectangles (whole-square coasts, land base, textures, bulbs, ...) are the renderer's constants
  with their DOS addresses (user D6). The government portraits that later overwrite (160, 140,
  160x60) of page 2 (O5:1AF6) are run-time state (area B, D7).

### E.9.3 The cut table (DOS order; verified against `ovl05.lst` on 2026-10-11)

The page-1 work buffer holds the named picture from that row on. Rectangles are `(x, y, w, h)`
in page pixels, as `G#2(1, x, y, w, h)` receives them. Every row was read in the listing (the
pushes before each call of R:0000:077D = `G#2` and the store's displacement, for example
`[di - 0x4d86]` = B27A); every row agrees with SPRITES.

| # | Family (DOS receiver) | Page 1 holds | Entries | Rectangle | O5 range | SPRITES |
|---|---|---|---|---|---|---|
| 1 | REPORT (DF62) | `SP299.PIC` (O5:1474..147C) | i 0..2 | (160 + 42i, 142, 41, 58) | O5:14AC..14E3 | 3 |
| 2 | TERRAIN (B886) | `TER257.PIC` (O5:14EF..14F7) | 16t + m, t 0..5, m 0..15 | (16m, 16t, 16, 16) | O5:14FF..1577 (cut 1538..1563) | 4 |
| 3 | TERRAIN | same | 16t, t 6..9 | (0, 16t, 16, 16) | same | 4 |
| 4 | TERRAIN copies | (no cut) | 16t + m, t 6..9, m 1..15 | entry 16t + m - 1, so 16t | O5:1506..1518 | 4 |
| 5 | COAST (D294) | same | 4i + k, i 0..7, k 0..3 | k 0 (16i, 176), k 1 (16i + 8, 176), k 2 (16i + 8, 184), k 3 (16i, 184); 8 x 8 | O5:1579..15F7 | 4 |
| 6 | MOUTH (D2D4) | same | d 0..3 | (128 + 16d, 176, 16, 16) | O5:15F9..1635 | 4 |
| 7 | ROAD (B27A) | `SP257.PIC` (O5:16BA..16C2) | i 0..7 | (16i, 48, 16, 16) | O5:16F5..1745 (store 171C) | 6.1 |
| 8 | RAIL (B29A) | same | i 0..7 | (128 + 16i, 96, 16, 16) | the same loop (store 173A) | 6.1 |
| 9 | CITYTILE (B2BA) | same | 0 | (48, 32, 16, 16) | O5:1747..1760 | 6.1 |
| 10 | RIVER (6DFE) | same | i 1..15 | (16i, 64, 16, 16) | O5:1763..17AF (store 178A) | 6.1 |
| 11 | RIVER (6E1E) | same | 16 + i, i 1..15 | (16i, 80, 16, 16) | the same loop (store 17A4) | 6.1 |
| 12 | PALACE (D21C, D244, D26C) | same | 20s + i, s 0..2, i 0..19 | (160 + 7i, 16s, 7, 15) | O5:17B1..1824 | 6.2 |
| 13 | EDGE (7EEC) | same | i 0..3 | (80 + 16i, 128, 16, 16) | O5:1826..185B | 6.1 |
| 14 | ICON (D4CE) | same | i 0..6 | (16i, 32, 16, 16) | O5:185D..188F | 6.3 |
| 15 | ICON copy (D4DC) | (no cut) | 7 | TORCH 0 | O5:1891..1894 | 6.3, 6.5 |
| 16 | ICON (D4DE) | same | 8 + i, i 0..7 | (129 + 8(i & 3), 33 + 2(i & 4), 7, 7) | O5:1897..18D7 | 6.3 |
| 17 | CITIZEN (6E96) | same | i 0..8 | (8i, 128, 8, 16) | O5:18D9..190E | 6.5 |
| 18 | ICON (D4EE) | same | 16 + i, i 0..15 | (16i + 1, 113, 15, 15) | O5:1910..1943 | 6.3 |
| 19 | ICON (D50E) | same | 32 + i, i 0..7 | (16i + 1, 97, 15, 15) | O5:1945..1978 | 6.3 |
| 20 | GRASS (B880) | same | 0 | (153, 41, 7, 7) | O5:197A..1993 | 6.1 |
| 21 | NEWS (DF0C) | same | 0 | (176, 128, 20, 9) | O5:1996..19B2 | 6.5 |
| 22 | ICON units (D54E) | `SP257.PIC`, rows 128..159 recoloured per civilisation (E.9.4) | 64 + 32c + j, c 0..7, j 0..27 | (16(j mod 20) + 1, 16(j div 20) + 129, 15, 15) | O5:19B5..1A06, 1AE3..1AE8 | 6.4 |
| T | TORCH (6E92) | `TORCH.PIC` alone (R:1FA1:044C at R:01A8:010B, mode 0) | 0 | the whole 13 x 14 picture; each row the first `width` pixels (`G#35`, `G#34`) | R:01A8:0102..0116 | 6.5 |

Row T runs before O5:1455 in DOS (R:01A8:0102 precedes R:01A8:0810) and first in the port, because
row 15 copies it. Rows 1..21 never write the work buffer; row 22 does (E.9.4), after every other cut
from rows 128..159 (rows 13, 17, 21) is done, as in DOS.

In C the table is one `static const PdosCut` array in DOS order:

> **C passage condensed for the public copy.** The original record has here a block of 8 lines of C declarations: types `PdosCut`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

Every row above fits this form (row 5 as four entries with `step` 4, one per quarter; row 16 with
`per_row` 4, `cx` 8, `ry` 8; row 12 with `per_row` 20, `cx` 7, `ry` 16).

### E.9.4 The unit recolouring (O5:19B5..1AE8; SPRITES 6.4)

For c = 0..7, on the work buffer, with `main = low byte of CIV_MAIN_COLOUR[c]` and `second = low byte
of CIV_SECOND_COLOUR[c]` (`G#3` uses the low bytes, DRIVER G#3; the registry admits 0..15):

1. copy rows 160..191 to rows 128..159, 320 x 32, opaque (`G#20`, O5:1A14..1A32);
2. if `main` is 15: every pixel 15 in (0, 128, 320, 32) becomes 11 (`G#3`, O5:1A3F..1A61);
3. if `main` is 7: every 7 becomes 3 (O5:1A6E..1A90);
4. every 10 becomes `main` (O5:1A98..1AB8);
5. every 2 becomes `second` (O5:1AC0..1ADB);
6. cut the 28 units of row 22 (O5:19C5..1A02).

Each step is a full pass over the strip in this order, as `G#3` is called (DRIVER G#3: "every pixel of
the rectangle equal to old becomes new"). The order matters in general (a `main` of 2 would let step 5
recolour step 4's pixels). Scratch: for the pinned colour words no main colour is 2, and the
sequential passes equal a one-pass map for all eight civilisations, but the port implements the
passes as DOS does and relies on neither. Rows 160..191 are never changed (scratch), so each
civilisation starts from the same art.

### E.9.5 The pointer (FORMATS 4; SPRITES 6.3, 6.5; RV1-7)

* The DOS pointer has only two shapes: the torch, ICON 7 (= TORCH 0), and the GO arrow, ICON 2. The
  hot spot is (0, 0) for both. The torch is drawn with the current palette (mode 0, FORMATS 4); which
  shape shows when is area A's and D's (OPEN L5, P21). The old `pdos_pointer` (k 0..7) is withdrawn:
  ICON 0, 1 are empty and ICON 3..6 are map overlays, not pointers (FORMATS 4).
* E delivers palette indices with 0 transparent. On area A's cursor route (RV1-7: `w16_SetCursor` →
  `present_cursor` → `host_set_cursor_pixels`) the conversion is done by the DOS profile's `cursor`
  callback, which area B implements (B 6.7, A 8.5): it converts them with the shown canvas's palette,
  and A re-issues the pointer when the palette or the profile changes. (Revision 3 wording, B's E-B4 and
  X8; no change to E's interface.)

### E.9.6 Limits, failure, cost

* Before use (at step 7): every rectangle of the table lies inside 320 x 200 (a table defect gives
  `PDOS_E_FORMAT`, reason "shape cut"). `SP299.PIC`, `TER257.PIC` and `SP257.PIC` must be 320 x 200
  X0 and `TORCH.PIC` 13 x 14 X1 (pinned; checked again). `CIV_MAIN_COLOUR` and `CIV_SECOND_COLOUR`
  are validated by the registry (8 words, 0..15).
* Memory: one block for all cut pixels, its size summed from the table before allocation (114,709
  bytes: 524 grabs plus the torch, scratch), plus the entry arrays (586 entries, about 9 KB); the
  64,000-byte work buffer is freed after step 7. No allocation afterwards.
* Time: 114,709 bytes copied and 8 x 4 passes over 10,240 pixels, under 1 ms (estimate).
* Accessors are pure reads with bounds checks; they never fault (O3 applied to E's data).

### E.9.7 Not in this module

* Draw-time recolouring by the scenes (the city overlay's 5 to the secondary colour, sentry 5 and 8
  to 7: SCENES-PLAY 2.2, 2.3) is drawing, area D.
* The ICONPG cells (SPRITES 8) are copies from decoded pictures by grid constants in the renderer;
  their lookup tables are registry tables (E.10.3).
* The Windows-side differences (SPRITES 9; OPEN P11, the unit column offset) are areas B and D's.

**Choice (one owner, procedure reproduced):** E reproduces O5:1455 as a whole, with its order,
copies and recolouring. Alternatives: each renderer cuts its own rectangles from the pictures
(scatters the cut order, the terrain copy rule and the recolouring over areas B and D); per-shape
offsets read from the image (the immediates' offsets are not recorded, OPEN P28, and gain nothing
under D6). **Choice (when):** at activation with the rest of the store (RV1-1). Alternative: at the
first use of a family, which would allocate during a run.

## E.10 Data tables: the offset registry

### E.10.1 `docs/dos/OFFSETS.md`

One Markdown table that `registry.py gen` parses (as `gen/trace.py` parses TRACE.md). Columns:

| Column | Content |
|---|---|
| Id | `UPPER_CASE`, becomes `PDOS_T_<Id>` |
| Address | `R:ssss:oooo`, `DGROUP:oooo`, `O<n>:oooo`, `G:0000:oooo`, or `[DGROUP:oooo]:oooo` (a relocated segment word, then an offset). Only initialised data: DGROUP below 6B30h, the far data segments R:2604..R:2772, the driver's data (FORMATS 6 "Where image data can be"). Run-time storage (FORMATS 6.3: shape handles, buffers, ports) is refused; the shapes come from `pdos_shapes` (E.9). |
| Kind | `bytes`, `u16`, `str` (one NUL-terminated string), `strs` (Count consecutive strings), `ptrs` (Count near DGROUP pointers to strings), `imm8`/`imm16` (an instruction operand; optional under D6) |
| Count, Stride | elements and bytes per element (`bytes`: Count = length) |
| Max | the longest string allowed (`str`, `strs`, `ptrs`) |
| Shape | a check: `-`, `last=FFFFh`, `groups0=8x3` (zero-terminated groups of triples, 8 groups), `range=0..15` |
| Readers | the DOS listing addresses that read it (the evidence) |
| Writers | DOS listing writers found (`none` after the scan of E.13.4); with writers the file value is only the initial value and the renderer models the writes |
| Source | D0 document and section |
| Phase | the consuming phase (D4..D7) |

### E.10.2 Generated descriptors and run-time access

> **C passage condensed for the public copy.** The original record has here a block of 13 lines of C declarations: types `PdosTableDesc`; functions `pdos_table`, `pdos_table_u8`, `pdos_table_u16`, `pdos_table_str`. This repository publishes no code (see the repository README); the names above are kept so that the surrounding text can still be followed.

* Validation at activation (`PDOS_E_REGISTRY` on failure): the range lies inside its space and, for
  DGROUP, below the initialised extent 6B30h; a segment reference's word is a relocation target
  (`pdos_image_is_reloc`) and the referenced range lies in the root; strings end within Max and
  inside the space; `ptrs` targets are DGROUP offsets inside the initialised extent; the Shape
  holds.
* Accessors return pointers into the immutable image, never copies; out-of-range indices give a
  defined value (0 or NULL) and a presentation diagnostic (area A's diagnostic channel), never a
  fault (the O3 discipline applied to E's own data).
* **Choice:** renderers read DOS data only through registered tables, so every DOS data read is in
  OFFSETS.md with its evidence. Alternative: raw address access (untraceable).
* **Immediates** (FORMATS 6.2; OPEN P28, settled in E.16): per the user's D6 and ext-d1-decisions
  E.18-5 they are C constants with their DOS address next to them, as in E.9.3. The kinds
  `imm8`/`imm16` stay available for a phase that prefers to read a run of immediates from the image
  at a recorded instruction offset (validated offline against the listing, E.13.4); v1 has none.

### E.10.3 Seed entries (from FORMATS 6.1; each verified when added, confirmed by its consumer)

FORMATS 6.1 is the list of candidate tables. OFFSETS.md takes a row when its first consumer is built
(column "Added"); D2 adds the two colour tables because `pdos_shapes` needs them, and the rows that
D2's tests can already verify.

| Id | Address | Kind | Count | Shape | Readers | Source | Added |
|---|---|---|---|---|---|---|---|
| CIV_MAIN_COLOUR | DGROUP:1946 | u16 | 8 | range=0..15 | O5:1A3F, 1A6E, 1A9D (shapes); R:1AEA:03BA cities | FORMATS 6.1; SPRITES 6.4; SCENES-PLAY 2.3 | D2 |
| CIV_SECOND_COLOUR | DGROUP:1956 | u16 | 8 | range=0..15 | O5:1AC0 (shapes); R:1AEA:03BA cities | FORMATS 6.1; SPRITES 6.4; SCENES-PLAY 2.3 | D2 |
| BIRTH_CYCLE | R:2710:0000 (segment also in DGROUP:6416) | bytes | 131 | groups0=8x3 (3, 7, 5, 8, 5, 4, 4, 5 triples) | O7:1A9B..1B27 (running offset DGROUP:3B66) | FORMATS 6.1; PALETTE 2.6, 4; TIMING 5.5 | D2 (used D4) |
| BIRTH_SCHEDULE | R:2710:0083 | u16 | 45 | last=FFFFh | O7:17CF after each event (clamp R:1DC4:007C) | FORMATS 6.1; TIMING 5.5 | D2 (used D4) |
| TITLE_MENU | DGROUP:1AE2 | str | 1 (Max 128) | - | R:01A8:0486 | FORMATS 6.1; SCENES 6 | D4 |
| TEXT_TOKENS | DGROUP:30AE | ptrs | 5 (Max 8) | - | R:1F4D:0471 | FORMATS 6.1, 3.3 | D5 |
| REPORT_CAPTIONS | DGROUP:2FA6 | ptrs | 7 (Max 32) | - | R:1D05:05ED..0753 | FORMATS 6.1; SCENES-PLAY 0.2 | D7 |
| DIR_STEP_X, DIR_STEP_Y | DGROUP:1882, 18E4 | u16 (signed by the consumer) | 49 each | entries 0..8 in -1..1 | to be named by D6 | FORMATS 6.1; SPRITES 6.1 | D6 |
| ICONPG_ADVANCE | [DGROUP:6420]:0000 (R:271E) | bytes | 72 (the search runs 4 bytes into the next table) | - | O8:16C4 | FORMATS 6.1; SPRITES 8 | D7 |
| ICONPG_UNIT | [DGROUP:6420]:0044 | bytes | 28 | - | O8:1790 | same | D7 |
| ICONPG_TERRAIN | [DGROUP:6420]:0061 | bytes | 12 | - | O8:17C3 | same | D7 |
| DRV_DEFAULT_PALETTE | G:0000:1410 (MGRAPHIC data:0050) | bytes | 384 | range=0..63 | G#37, G#26, G#27 | FORMATS 6.1; DRIVER 3.5; PALETTE 2.1 | area B (OPEN P4) |

The wonder rectangles `[DGROUP:6444]` and the throne-room table `[DGROUP:640A]` wait for their
lengths (FORMATS 6.1 "not established"; OPEN L1, D7); their segment words are relocated (scratch).
The first 16 bytes of `[DGROUP:640A]` (file R:26FA:0000..000F) are also area B's leader-font table
(B 10.1, values 0..2 giving fonts 8, 9, 3); B's E-B2 asks for it as the D7 row `LEADER_FONT`
(offset 0, 16 bytes, range 0..2). The D7 row and a FORMATS 6.1 correction record both uses (RV2-17;
Revision 3 wording, no interface change).
Strings the scenes draw (FORMATS 6.1, DOS-PROFILE 3.4) are added by the phases that draw them.
Correction from revision 1: DGROUP:1946/1956 are word tables (the cutter compares `word ptr
[bx + 1946h]` with `bx = 2c`, O5:1A3F) and DGROUP:1882/18E4 hold 49 words each (FORMATS 6.1).

## E.11 Memory safety rules (all decoders)

* Every read goes through a bounded reader (`PdosRd { const uint8_t *p; uint32_t n, pos; }`) whose
  functions return a status; no decoder indexes a buffer without a prior bound check.
* Sizes are checked before `host_alloc` (which never returns NULL and is fatal on failure): every
  allocation is bounded by a pin size, `D <= A0000h`, `w*h <= 64000`, or a count derived from those.
* 32-bit unsigned arithmetic with explicit overflow checks; 64-bit only for products of two 32-bit
  values.
* Fixed arrays for LZW (`prefix[2048]`, `suffix[2048]`, stack 2,049) with indices masked by the code
  width (at most 11 bits) and a checked `next < 2048` before each store.
* Decoder results: `PDOS_D_OK` or one of `PDOS_D_TRUNC`, `_MZ`, `_EXEPACK`, `_CHUNK`, `_SIZE`,
  `_LZW`, `_FONT`, `_TEXT`, `_SHAPE`; activation maps any of them to `PDOS_E_FORMAT` with the reason.
* The shape cut checks every rectangle against 320 x 200 and every source picture's size before it
  touches the work buffer; entry indices are bounded by the family's DOS count (E.9.2, E.9.6).
* No recursion, no static mutable state in decoders (the store's state is in `pdos_assets.c` and
  `pdos_shapes.c`, written only during activation).

## E.12 Costs (estimates; D2 measures and records them)

| Item | Size | Estimate (Release) |
|---|---|---|
| Read the 158 required files | 1,918,109 bytes (scratch sum) | warm cache a few ms; cold disk tens of ms |
| SHA-256 of the files and the two derived images | about 2.1 MB | 10..20 ms (portable `sha256.c`) |
| EXEPACK | 203,584 bytes out, 437 commands | under 1 ms |
| Decode 106 pictures | 6,195,610 pixels (scratch) | 20..60 ms |
| Fonts, texts, tables | 0.15 MB | under 2 ms |
| Shape cut (E.9.6) | 114,709 bytes of shapes, 8 x 4 recolour passes over 10,240 pixels | under 1 ms |
| **Memory kept** | decoded pixels 6.2 MB, shapes 0.12 MB, root 0.2 MB, `CIV.EXE` 0.3 MB (overlays), texts 0.13 MB, `FONTS.CV`, joined section texts about 0.13 MB | about 7 MB; the peak during activation about 9 MB |

Budget: activation at most 150 ms in Release on this machine (printed by `test_dos`; Checked and
Asan informational). Over budget: decode lazily at first use with the same cache, keeping the eager
check (Open E1).

## E.13 Tests

### E.13.1 `tests/test_dos.c` (7.6; Checked and Release now, Asan in the final run)

Arguments as every test program; the DOS copy is `<gamedata>\..\dosdata`; outputs under the test
output folder. Checks, each counted like `test_zip`'s `CHECK`:

1. **Pins**: each `req`/`opt` pin against the file in `build/dosdata` (size, SHA-256); the generated
   table equals `tests/dos-files.txt` (the generator ran this build).
2. **Activation, folder** (`hh_set_dos_source(dosdata)`): `PDOS_OK`; elapsed time printed.
3. **Activation, ZIP**: the test builds an in-memory stored ZIP (method 0, CRC-32 from
   `zip_crc32`) of the 158 files under a subfolder plus one unrelated folder; `PDOS_OK` and equal
   decoded hashes. One file left out: `PDOS_E_MISSING` naming it; one byte changed in memory:
   `PDOS_E_HASH` naming it.
4. **Failures by injection** (`hh_dos_inject`): missing, size, error and flip for the first, a middle
   and the last file of the list; each gives the expected status and a message naming that file;
   no source: `PDOS_E_NONE`.
5. **EXEPACK** (7.6): the root equals `CIV_UNP.EXE`'s load module byte for byte; relocations equal
   in set and in order; real CS:IP and SS:SP equal its header; the derived hashes equal the pins;
   23 overlays, numbers 1..23, ending at the end of the file, each equal to the same bytes of
   `CIV_UNP.EXE`'s tail. Any relocation difference is printed (expected none: scratch).
6. **Decoded content** (7.6 "decoded hashes are recorded"): every picture's `px` (with `w`, `h`,
   `x1`) and `m0`, every font's file slice and metrics, every line file's records, every
   section name's lookup result and joined text, every shape family (E.13.7) and every registered
   table's bytes, hashed and compared with `tests/dos-decoded.txt`; the actual list goes to
   `<out>/dos-decoded.txt` for a diff.
7. **Section lookups**: the read-only DOS lookup for every name equals the kept result; a name that
   is not in a file gives -1.
8. **Registry negatives**: a descriptor beyond 6B30h, one with an unrelocated segment word and one
   whose string is not terminated are refused (descriptors built in the test).
9. **Malformed input, real files changed in memory** (7.6 "lengths changed in memory"):
   * truncations of every file kind at 0..4 bytes, at each chunk or header boundary ±1, at 8 points
     inside the code stream and at the length minus 1;
   * field edits: chunk lengths (0, odd, beyond the end, FFFFh), width and height (0, 321, 201,
     FFFFh), the maximum-width byte (0, 8, 9, 12, FFh), `M0` first/last swapped, MZ fields (`e_cp`,
     `e_cblp`, `e_cparhdr`, `e_crlc`, `e_lfarlc`), EXEPACK fields (signature, IP, `exepack_size`,
     `dest_len` 0 and FFFFh), one command byte, one count word, a relocation group count, overlay
     headers, font count, font offsets, `bpr` 0 and 3, `last < first`, a text record of 300 bytes,
     a section file of 511 bytes, a text without its end marker;
   * deterministic bit flips (a fixed LCG): 32 per file, 512 for twelve chosen files (X0 and X1,
     odd widths, `TORCH`, a palette, `CIV.EXE`, `FONTS.CV`, `KING.TXT`, `CREDITS.TXT`);
   * every result is a clean status: success with output inside its bounds, or an error code; never
     a crash (ASan finds any out-of-bounds access in the final Asan run).
10. **Hand-written synthetic vectors** (no DOS bytes; the test holds a small LZW+RLE encoder): KwKwK
    codes, width growth at 1FFh/3FFh/7FFh, a reset at entry 2047, a first code above FFh after a
    reset (refused), an expansion through entry 100h (refused), `c > next` (decoded as next), the
    last code one bit short (refused), `90h 0`, `90h 1` (256 copies after the earlier one), runs
    and strings across rows, X1 odd width (`w` columns kept), a palette-only file, two `M0` chunks
    (refused), an `M0` of 772 bytes and a chunk of 6,146 bytes (refused); EXEPACK images built by the test with
    fill/copy commands touching the in-place limit (accepted) and one overwriting unread bytes
    (refused); fonts with one and two bytes per row and a 9-pixel glyph borrowing the next byte;
    texts with lone CR, blank lines, leading blanks, an early 1Ah.
11. **No writes**: size, SHA-256 and `_stat` modification time of every `build/dosdata` file are equal
    before and after; the files are read-only, so a write request would already fail.
12. **Determinism and leaks**: two activations give identical hashes; after `pdos_assets_close`,
    `hh_live_allocs` is back to its value before the first activation.

Budget: under 30 s in Checked (counts printed; the bit-flip numbers shrink if the measured time is
higher, recorded).

### E.13.2 Goldens from an independent decoder

`gen/dos/registry.py goldens` writes `tests/dos-decoded.txt` from the Python viewers (`pic.py`,
`fontcv.py`, `texts.py`, `dosexe.py`) and its own table reads: hashes, sizes, names. The C decoders
must agree with them. **Choice:** the goldens come from the Python tools that D0 verified against
the listing (exact consumption of every file), not from the C decoder's own first output.
Alternative: record the C output (self-referential).

### E.13.3 Win32-headless (`tests/win32/test_locate.c`, extended)

`hw_set_dos_source` over `build/dosdata` and over a ZIP made by the test: names in any case, a name
with a separator or `..` refused, a directory of that name counts as missing, a size mismatch is
`HOST_DOS_SIZE` without reading, `host_dos_where`; `civ64_dos_dir_ok`: equal paths (also with a
trailing separator and another case) refused, an inside folder accepted (E.18-1). Locate during a
run (E.3.6, with area A's handler): after the handler stores a choice, `pdos_assets_status()` and
the addresses returned by `pdos_pic` and `pdos_shape` are unchanged and `civ64.cfg` holds the new
`dos_data`.

### E.13.4 `gen/dos/registry.py check` (REGISTRY_OK, run by test.cmd)

* `tests/dos-files.txt` against `docs/dos/dos-hashes.txt` and `build/dosdata`; the derived hashes
  against `CIV_UNP.EXE`; `CIV64_DOS_EXE_SHA256` against the pin.
* Each OFFSETS.md row: the range inside its space and the initialised extent; each Readers address
  exists in the listings (`build/dos/disasm/`, regenerated by `disasm.py` when absent) and its
  instruction or function references the address (operand match, best effort, printed); a scan of
  the listings for memory writes into the range (destination operands), which must match the
  Writers column; the Shape on the data; `imm` entries' operand bytes equal the listing's operand.
* The cut table of `pdos_shapes.c` (E.9.3; parsed from its one `static const PdosCut` array, which
  the check requires to keep one row per line): each row's O5 range lies in `ovl05.lst` inside
  O5:1455; it contains a call of R:0000:077D (`G#2`), or for row 15 the load of [6E92] and the store
  to [D4DC]; it contains a store of AX whose displacement equals the row's `disp` field and lies in
  the family's DGROUP range (for example `- 0x4d86`, B27A, for ROAD; `+ 0x6e1e` for row 11, whose
  loop index starts at 1); the literal pushes
  of the range (`mov ax, imm` before `push ax`) include the row's literal constants (w, h, and x0 or
  y0 where they are literals). The recolour constants (O5:1A14..1ADB: 80h, 140h, 20h; 15 to 11, 7 to
  3, 10, 2) and the DGROUP:1A3E test at O5:152B are matched the same way. Best effort with every
  comparison printed; a mismatch fails REGISTRY_OK.
* The include rule of E.2.2 for `present/dos/pdos_*.c`.

### E.13.5 D-1 "No DOS byte is in the repository or the binary" (`gen/dos/nodos.py check`)

Winnowing: index every 32-byte window of every DOS file that starts at a multiple of 16 and has at
least 8 distinct byte values; scan every file of `claude/port` except `build/` and `.git`, and the
built `civ64.exe`, `civ_harness.exe` and `test_*.exe`, at every offset. Any copied run of 47 bytes
or more (32 + 15) is found; low-entropy runs (zeros, FFh) are not indexed. Prints NODOS_OK or each
hit with file and offset. **Choice**; alternative: a manual review only. Short quotes of a few
words in docs (allowed by 2.3) stay below the window.

### E.13.6 P0 at D2 (before area A's full 7.3 runner)

`tests/harness/ext_g1.py` gains a `--variant dos` run of a subset (S1 title, S3 new game to turn 5,
one load scenario, `p49-prf-game`): with `--dos-data build\dosdata`, and with
`--dos-data build\dosdata --dos-inject FONTS.CV:flip`. Core frame lines, snapshot and result lines
and `events.log` must equal the frozen baseline (`ext-g1-baseline.txt`); `dos-assets.log` must say
`status 0` in the first case and name `FONTS.CV` in the second. D3's runner (area A) then covers
every scenario with switching; every DOS variation of 7.3 and 7.4 passes `--dos-data build\dosdata`
(RV1-5), and the runner asserts from `profiles.log` that the switches happened and none was refused
(A's assertion; E's part is the harness option and `dos-assets.log`).

### E.13.7 Shapes (`pdos_shapes`; in `test_dos.c`, Checked and Release, Asan in the final run)

1. **Goldens.** `gen/dos/shapes.py goldens` (an independent Python model written from SPRITES 2..6,
   on `pic.py` output) writes one line per family entry to `tests/dos-decoded.txt`:
   `shape <FAMILY> <index> <w>x<h> <sha256 of px>`, `shape <FAMILY> <index> uncut`, or
   `shape <FAMILY> <index> same <FAMILY> <index>`. The C store must produce the same lines.
2. **Structure.** `pdos_shape_count` per family (3, 160, 32, 4, 8, 8, 1, 32, 60, 4, 320, 9, 1, 1, 1);
   the uncut set is exactly ICON 40..63, ICON 64 + 32c + 28..31 and RIVER 0, 16 (NULL with
   `dos_shape_uncut`); the all-zero cut shapes are exactly ICON 0, 1, 18, 27 (scratch); pointer
   equality for TERRAIN 16t + m and 16t (t 6..9) and for ICON 7 and TORCH 0, inequality for t 0..5;
   every size as the table; out-of-range family and index give NULL and `dos_shape_range`.
3. **Recolouring.** A synthetic page (test-made, no DOS bytes) with the colours 2, 3, 7, 10, 11, 15
   in rows 160..191, run through the unit step with test colour tables (main 15, 7, 2, 10 and
   second 10, 2, 11): every resulting pixel equals the sequential DOS rule of E.9.4 (for example main
   2 turns the 10s into the secondary colour), and rows 160..191 are unchanged.
4. **Listing.** `registry.py check` (E.13.4) ties every cut row to its O5 range.
5. **Malformed.** A test-built cut table with a rectangle reaching x 321 or y 201, and a source
   picture of another size (a decoded picture with its width changed in memory), give
   `PDOS_D_SHAPE`; a colour table entry of 16 is refused by the registry (E.13.1 item 8).
6. **Cost and leaks.** Shape bytes 114,709 and 586 entries printed; included in item 12's leak check.

## E.14 P0: why this area cannot change a checkpoint, the virtual screen or the base trace

* **No emulation state.** E's modules include no emulation header (E.2.2, checked by E.13.4); they
  cannot reach images, selectors, handles, the emulated stack, `vm_steps`, `vm_site`, statement
  markers, `fr_enter`, the queue, the key state, the cursor or `g_randSeed` (O4).
* **No core input.** E never opens a file of the data directory; the DOS source is a different
  folder (equality refused, E.3.3) or a ZIP in memory; a DOS folder inside the data directory is
  invisible to the virtual DOS (`dos.c` `resolve` depth 2, `host_dir_list` files only).
* **No virtual time.** Activation, including the shape cut, runs before
  `w16_clock_reset`/`w16_host_start` in civ64 (`civ64_main.c` 246..260) and before `vm_init` in the
  harness (`harness.c` 1061), and never again during the run (E.3.6). After activation E reads no
  clock and does no work except pure memory reads, so even `--timing host` sees no E work during
  the run.
* **No core random numbers.** The shape cut and every decoder are deterministic functions of the
  pinned files; nothing in E reads `g_randSeed` or calls a generator.
* **No presentation side effects on the base trace.** E does not call `w16_present`, `present_core`
  or `host_present`, and touches neither the dirty state, `g_last_present_us` nor the harness frame
  counter; its log is a separate file.
* **Host heap only.** `host_alloc` is the host's heap; the headless allocation counter is not part
  of the base trace or any checkpoint.
* **Tests that catch a breach:** `ext_g1.py` (G-1, unchanged runs) and its `--variant dos` (E.13.6)
  compare core frames, snapshots and events with the frozen baseline; the include rule
  (E.13.4) catches an emulation header in E's modules.

## E.15 Rules of the prompt in this area

| Rule | How the design meets it | Test |
|---|---|---|
| 2.3 No DOS bytes | Only offsets, sizes, hashes, format constants (`MZ`, `RB`, chunk tags, as immediates under D6) and DOS addresses in source; pins and goldens are hashes | `nodos.py` (E.13.5) |
| 2.3 DOS immutability | Read-only service; P8 settled | E.3.5, E.13.1 item 11, section-10 hashes |
| 5.1 host.h | `host_dos_read`, `host_dos_where` | E.13.1, E.13.3 |
| 5.9 directory | R's lookup (D8); equality refused, inside accepted (E.18-1) | E.13.3 |
| 5.9 pinning, first use | `tests/dos-files.txt`, generated table, check at activation (E.18-4) | E.13.1 items 1..4 |
| 5.9 missing or different files | exit 2 with `--graphics dos`; else unavailable for the run, A's one message then beeps (RV1-8); Locate effective at the next start (RV1-6) | E.13.1 item 4; E.13.3; area A's chord test |
| 5.9 program image | EXEPACK, derived hashes, `CIV_UNP.EXE` alternative (headless, E.18-2), overlays | E.13.1 item 5 |
| 5.9 decoders follow the listing | E.6..E.8 with DOS addresses; Python mirror | E.13.1 items 6, 7, 10; E.13.2 |
| 5.9 sprite rectangles and layouts | the cut O5:1455 reproduced (E.9); rectangles are immediates kept as constants with their O5 addresses (D6, E.18-5); the colour tables read at run time | E.13.7; E.13.4 |
| 5.9 data tables at recorded offsets | OFFSETS.md registry (initialised data only), generated descriptors, validation | E.13.1 item 8; E.13.4 |
| D-5 (the DOS map's art) | every shape D 14 uses comes from `pdos_shapes` by family and DOS index (E.9.2) | E.13.7; D's tests |
| 5.9 palette rule, out of scope | raw 6-bit values handed to area B; `E0` skipped; sound not read | - |
| 5.4 static text from DOS | raw texts and registered strings | E.13.1 item 6 |
| 5.10 fonts | font data and `G#4`/`G#12` models; drawing in area B | E.13.1 items 6, 10 |
| O3 (applied to E's data) | accessors never fault, defined values and a diagnostic, no allocation after activation | E.13.1 item 12 |
| O4 | E.14 | E.13.4, E.13.6 |
| O1, O2, O5..O7, T1..T7, I1..I8, 5.3, 5.8 | no events, probes, timelines or input in this area; E supplies pictures, palettes and tables that those designs consume | - |
| D-1 | all of the above | E.13 |
| 7.6 | E.13.1 (Asan deferred) | - |
| G-2 | `present/dos` in the three language checks | build.cmd |

## E.16 OPEN.md items

* **P8, settled** (E.3.5): never written; the DOS lookup is run read-only without its cache write;
  the index-full hang cannot occur (256 probes, then the scan).
* **P28, settled** (E.9, E.10.2): code immediates (FORMATS 6.2) are C constants with their DOS
  address as provenance (user D6, ext-d1-decisions E.18-5); the cut table's rows are checked
  against the listing by `registry.py check` (E.13.4); data tables are read through OFFSETS.md.
* **X10, recorded** (E.9.1): DGROUP:1A3E is taken as 0 (enough memory), so terrain rows 0..5 have 16
  variants; the threshold and DGROUP:6DFC stay unexplained, and the port does not need them.
* **Belonging elsewhere:** P1, P2, P6, P7, P10 (area C); P3 (areas C and D); P4, P5, P11, P13, P14,
  P23 (area B, with E's `DRV_DEFAULT_PALETTE` table as P4's reference and the raw 6-bit `m0` for
  P23); P9 (area D); P21 (areas A and D: which pointer shape for the busy and small-map cursors);
  P27 (area B and D4/D7: E supplies the 197 real columns); the other P items to their areas.
* **Touched here, left open:** O7 (odd-width rows, with P27); L5 (when the GO arrow shows; E gives
  both pointer shapes, E.9.5); L16 and FORMATS Open 2 (the headerless loaders R:1FA1:02A2/05A0: an
  entry point `pdos_pic_decode_raw` is added only if a renderer needs it); X5 (the archive lookup
  R:1FA1:0728: not implemented, no archive in the release); X7 (missing texts: in the port a missing
  required file makes the profile unavailable, so the DOS NULL-stream behaviour never arises);
  X11 (uncut art of `SP257.PIC`/`TER257.PIC`: available through `pdos_pic` if a renderer finds a
  user); X14 (R:0000:04AA's view of `m0`, kept in `PdosPic.m0`); FORMATS Open 7 (`byte7` kept,
  unused).

## E.17 Open (this area)

* **E1** Activation cost against the 150 ms budget: measured in D2 (`test_dos`); lazy decode as the
  fallback.
* **E2** The final required set: pruned at D8 to the files the renderers open.
* **E3** Whether area B uses `MGRAPHIC.EXE`'s default palette (P4); if not, `MGRAPHIC.EXE` leaves the
  required set and `DRV_DEFAULT_PALETTE` the registry.
* **E4** Registry rows whose readers are still to be named (DIR_STEP_X/Y) and whose lengths are not
  established (the L1 tables [6444], [640A]): added by the consuming phases (D6, D7) once their
  readers and lengths are traced; `registry.py check` then verifies them.
* **E7** Low-memory condition: DOS would cut terrain rows 0..5 with one variant when DGROUP:1A3E is
  set (E.9.1). The port does not model it; if the user wants the low-memory look, it is one flag in
  the cut (resolved by a user request only).
* **E8** The arena-full case of `G#2` (E.9.1) is not modelled: every grab succeeds.
* **E5** Last-access time updates on the user's volume (E.3.5): a host fact, recorded in FIDELITY.
* **E6** SHA-256 and decode speed in Checked and Asan harness runs (each `--dos-data` run pays the
  activation once): measured at D2/D3.

## E.18 Conflicts and their resolutions (ext-d1-decisions.md)

All five conflicts of revision 1 are resolved by the orchestrator; the design follows the
resolutions.

1. **E.18-1 DOS folder inside the data directory** (5.9 against R step 4a with R step 3). Resolved:
   refused only when the two paths are equal; "inside" accepted because the core cannot reach a
   subfolder; recorded in FIDELITY (E.3.3, E.13.3).
2. **E.18-2 `CIV_UNP.EXE` "accepted instead"** (5.9) against R's validity rule. Resolved: phase R
   unchanged; the store supports `CIV_UNP.EXE`, reachable headless (E.5.3).
3. **E.18-3 D2 gate "7.6 passes under Asan".** Resolved (K8): Asan deferred; D2 records Checked and
   Release; `test_dos` (with E.13.7) joins the final Asan pass.
4. **E.18-4 "checked the first time it is needed"** read as "at activation, before the profile can
   first need it". Accepted (E.4.2).
5. **E.18-5 sprite rectangles and layouts** against the user's D6. Resolved: immediates inside DOS
   code are constants with their DOS address (E.9.3); data-segment tables are read at run time
   through the registry (E.10).

New in revision 2, nothing needing a decision: the shape module (RV1-1) applies E.18-5; the
low-memory terrain rule is recorded rather than modelled (E.17 E7), which changes no visible DOS
behaviour on a machine with enough memory.

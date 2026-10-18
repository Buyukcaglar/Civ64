# Extension BS, unit BS1 (Windows Birth assets) - record

Unit BS1 of the Birth synchronisation BS (the user's direction of 2026-10-15, session E3: "Perform Windows &
DOS Birth-* sync task ... adapt Windows scenes to DOS counterparts in terms of timing"). Brief:
[verify/BRIEF-bs.md](verify/BRIEF-bs.md) D1..D12 with the orchestrator's Rulings (14:40 UTC), section 3.2
item 1, 5.2 test 1, 6 (BS1 row). Rules: BRIEF-d4.md "Rules". Staged in `build/bs-stage` without the build
slot; the build slot landed it (below).

## Status

Done. Landed in the tree on 2026-10-15 at 23:35 UTC, BS1..BS4 at once (the BS implementer's build slot;
one landing for BS12 and BS34, no separate three-step cycles, Rulings 19:20) and verified by the BS phase
gate's eight-step cycle: ALL_GREEN (status `build/bs-status.txt`, logs `build/bs-<n>-<step>.log`; the gate
and its tables: [ext-BS-acceptance.md](ext-BS-acceptance.md)).
`host_win32.c` landed after UX1 (D12): the tree's file was UX1's copy, the base of this unit's block.
Nothing visible changes in BS1 itself: the store is opened by the harness's check options and, from BS3, by
the Birth synchronisation. In the gate: `test_pbs_assets` 58 checks in all three variants; `ext_bs.py assets`
EXT_BS_OK (10 checks; CheckedNoObs: the refusal), test.cmd section `bs1_assets`. The results below are the
staging's (private).

## What was built

### `host_data_read` (D2)

`platform/w16/host.h`: `int host_data_read(const char *name, uint8_t *buf, uint32_t cap, uint32_t *size)`
with `HOST_DATA_OK / MISSING / SIZE / ERROR`, the twin of `host_dos_read`: a plain 8.3 name of the run's
data directory's top level, ASCII case ignored; a file of at most `cap` bytes is read whole (OK, `*size`);
a larger one gives SIZE with its size (`cap` 0 or `buf` NULL asks the size); never a write, a create or an
attribute change. Only `present/bs` calls it, before the emulation starts; no core path does.

* Win32 (`platform/win32/host_win32.c`, one delimited block after `host_dos_where`): `g_datadir`,
  `dos_plain_name`, `hw_find_name` (files only), `CreateFileW(GENERIC_READ, FILE_SHARE_READ, OPEN_EXISTING)`,
  `GetFileSizeEx`, `ReadFile`.
* Headless (`tests/headless/host_headless.c`, `.h`): the same over `hh_set_datadir`'s directory, with
  `hh_data_inject(name, HH_DOS_MISSING | HH_DOS_ERROR | HH_DOS_FLIP)` for the tests (a NULL name clears).

### The store (`present/bs/pbs_assets.h/.c`)

Portable C. `pbs_assets_open` reads `CivData0..4.rsc` (a missing file is skipped, as OpenResFile does) and
keeps, by the core's precedence (the last file that has it, within a file the last reference with the id):
'CvPc' 128..135 decoded with colour base 0, and 'STR#' 139. All or nothing: any refusal closes the store
with a status (`ok`, `none`, `read`, `format`, `missing`, `decode`) and a one-sentence message.

* The resource map: OpenResFile 1190:0000 / AddRFileFromImage 1190:1692 over the image block (0x16E360
  bytes, 1190:003E); data at the file's data offset + the reference's 3-byte offset, length first
  (RestoMem 1190:0FDA).
* A caption: GetIndString 1100:078A (an index <= 0 or above the count gives the empty string).
* A picture: LoadGifPicture 10B8:11BC and PicDecompress 10B8:158C transcribed, including the
  decompressor's own effects on the raw-bits block (findings H11: the row-end copy through the selector of
  the last write at a 64 KB tile boundary; C15: the KwKwK end byte through destPos - 1); the colour table
  of 10B8:12E8..141C (`pbs_pic_color_table`: base..base + n - 1 from the file, the 236 clamp, flags 1 on a
  palette device). Refusals, never a fault: a short header, a minimum code size above 10, width or height
  0, more than 2^24 pixels, a truncated stream, a code beyond the table, output past width x height, a
  4097th entry without a clear code, any access outside the block.

### The checks (`present/bs/pbs_check.h/.c`, the asset part) and the harness

`--bs-check 1` (`tests/headless/harness.h`, `harness_main.c`, `harness.c`, delimited "extension BS"
blocks): after `hh_set_datadir(rundir)` the store is opened from the run directory (`bs-assets.log`: the
status, each picture's file, size, colour count and minimum code size, the captions' file and count; no
pixel, colour or text byte); after `obs_init` the checks register one observer listener and write `bs.log`;
the run's end (and every error path) writes the end line and closes the store. Under CIV_OBSERVER 0 the
option exits 2. The checks read the core through w16q_* only (P0):

* GR_PicRead 10B8:079D exit for 128..135: width, height, rowBytes, the raw-bits block's first
  width * height + 5 bytes and the colour table's 0x400 bytes against the store (g_noPaletteDevice read);
* GR_PortDataToBitmap 10B8:0E36 exit for that port: the port bitmap (graf.hBitmap) is
  width x height x 8 with the picture's pixels;
* DrawTextInRect 1098:0ED1 entry from AdvanceMovie (10B0:1280): the C string against GetIndString of the
  frame's text item (type 7, read from the movie's items), from the store for list 139 (PtoCstr: up to the
  first NUL); another list's text (another movie: the title's credits, list 137) is counted only.

### Tests

* `tests/test_pbs_assets.c` (58 checks; `tests/pbs_testdata.h` holds the synthetic data shared with BS2's
  test): an independent LZW model and greedy encoder; a literal stream; a 100 x 80 picture of runs and noise
  (KwKwK, width 12, clears) in sub-blocks of 1, 7 and 255 bytes; the H11 and C15 vectors on 512 x 300
  pictures; the refusals; the colour table with its clamp; resource maps (precedence, a second type, an id
  under another type, a map or data past the end); STR# semantics; the store over five synthetic files
  (precedence across files and within one, a missing file, an unreadable one, a corrupted one, a picture
  refused, a malformed map, a missing picture, no data directory); with the game data, the user's
  CivData*.rsc (sizes and captions only); no allocation kept.
* `tests/harness/ext_bs.py assets` (Checked; CheckedNoObs: the refusal): p4-birth's start (Enter at 22 s)
  to 200 s, without and with `--bs-check 1`; bs-assets.log ok; every picture read equal (pixels and colour
  table), every bitmap equal, the 44 captions equal, no mismatch; P0 (run.log's frame/snapshot/result/
  checkpoint lines, events.log and the summary line equal the unchecked run's).

## Results (private, `build/bs-stage/obj`, the overlay of the tree and this stage)

* Compilation: the BS sources, the tests and the harness strict (c11, c17 /W4 /WX, clang-tidy C99) in
  Checked, CheckedNoObs and Release: CC_STRICT_OK; the whole overlay including civ64.exe: CC_ALL_OK in all
  three variants. `obs_lint.py` over the overlay: OBS_LINT_OK (92 files).
* `test_pbs_assets`: 58 checks, 0 failed (Checked, CheckedNoObs, Release). The user's data: 128 1024x320
  153 colours, 129..135 512x320 224 colours (all from CivData1.rsc), STR# 139 from CivData0.rsc, 44
  strings; every picture decodes.
* `ext_bs.py assets Checked`: EXT_BS_OK, 10 checks: `end bs checks pics 9 bitmaps 9 texts 44
  other_texts 830 mismatches 0` (picture 128 is read twice); P0: 1930 lines equal. CheckedNoObs: exit 2
  naming `--bs-check`. About 18 s.

## Decisions within the brief

1. **Test 1's option.** 5.2 names `--birth-sync 1` for test 1, but `--birth-sync` is BS3's (D6). Test 1
   runs under a check-only option `--bs-check 1` (no visible change, P0 checked), which BS3 can keep.
2. **Who opens the store.** BS1's harness opens it under `--bs-check`/`--bs-mirror`. civ64's open (when the
   DOS profile is registered, D6) comes with BS3's files (`win64/civ64_start.c`, `present/present.c`), since
   nothing reads the store before BS3; BS1 changes nothing in civ64 but the host service. (Proposal; the
   orchestrator may move it into BS1's build-slot cycle instead: one call after `pdos_assets_open`.)
   Ruled at 18:10 UTC: civ64 opens the store only from BS3.
3. **Decode before the run** (3.2 item 1's proposal): all eight pictures at the open (about 1.5 MB of
   presentation memory); BS2's replica validates them against the script read at the Birth's start.
4. **The text check's attribution**: by the movie's own text items (type 7 starting at the frame, or with
   0x400), not by call order, so other movies' texts never mismatch.

## For the records

* **DESIGN.md 12.10 (host.h additions beyond prompt 5.1).** `host_data_read(name, buf, cap, &size)`: the
  data directory's top-level files, read only, whole, for the presentation (present/bs) before the
  emulation; never called on a core path (G-1). Both back ends; headless `hh_data_inject`.
* **DESIGN.md 12.8 "Added in BS".** `present/bs/pbs_assets` (the Windows Birth's store: .rsc parser,
  STR# reader, CvPc decoder with H11/C15), `present/bs/pbs_check` (the harness's checks).
* **RUNNING.md.** Harness `--bs-check 0|1` (default 0; CIV_OBSERVER 0: exit 2): `bs-assets.log`, `bs.log`
  (`bs pic`, `bs bitmap`, `bs text`, `end bs checks ...`). `tests/harness/ext_bs.py assets [Checked|
  CheckedNoObs] [--exe --root --port]`: 2 runs of 200 s virtual, about 18 s, in test.cmd's `bs1_assets`.
* **STATUS.md.** BS1 done (after the cycle): `test_pbs_assets` 58, `ext_bs.py assets` 10 checks.
* **FIDELITY.md, FEATURES.md, the checklist.** Nothing (nothing visible changes).
* **G-1.** Unchanged runs: no base harness run takes the new option.

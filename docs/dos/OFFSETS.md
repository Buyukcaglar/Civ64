# The offset registry of the DOS data tables (extension D2)

Written 2026-10-11 by the D2 implementer under `docs/verify/BRIEF-d2.md`, from the design
`docs/verify/ext-d1-draft-E.md` (revision 2) E.10 and the D0 list of data tables in
[FORMATS.md](FORMATS.md) 6.1. Prompt 5.9 requires every DOS data table the DOS profile reads to come
from the DOS image at a recorded offset, never from source. This file is that record. It holds
addresses, widths, counts and the evidence only: no DOS bytes.

`gen/dos/registry.py gen` turns the table below into `present/dos/pdos_registry.c` at every build
(a malformed row fails the build); `present/dos/pdos_tables.c` resolves and validates every row at
activation (`PDOS_E_REGISTRY` on a failure); `gen/dos/registry.py check` (run by `test.cmd`,
REGISTRY_OK) verifies each row against the DOS files and the listings in `build/dos/disasm/`.

## Rules

* **Only initialised data.** DGROUP below 6B30h (the root's load module ends at DGROUP:6B30, FORMATS
  6), the far data segments R:2604..R:2B00 (EXECUTABLE 4), the overlays' images, and the driver's data
  segment (`MGRAPHIC.EXE` load module from 13C0h, data:0000). Run-time storage (FORMATS 6.3: the shape
  handles, buffers, ports, the LZW dictionary) is never a table; the shapes come from `pdos_shapes`
  (design E.9).
* **Immediates are not tables.** Constants inside DOS code (FORMATS 6.2; the cut rectangles of
  O5:1455) are C constants with their DOS address next to them (the user's decision D6;
  ext-d1-decisions E.18-5). The kinds `imm8`/`imm16` stay available for a phase that prefers to read
  a run of immediates from the image at a recorded instruction address; this version has none.
* **A row is added by the phase that first consumes it** (column Phase), or earlier when D2's tests
  can verify it. The throne-room table `[DGROUP:640A]` waits for its length (FORMATS 6.1 "not
  established"; OPEN L1, D7). The wonder rectangles `[DGROUP:6444]` and the direction steps DGROUP:1882
  and 18E4 are rows since D7e, with the lengths their readers use (the notes below).

## Columns

| Column | Content |
|---|---|
| Id | `UPPER_CASE`; becomes `PDOS_T_<Id>` |
| Address | `DGROUP:oooo`, `R:ssss:oooo`, `[DGROUP:oooo]:oooo` (a relocated segment word in DGROUP, then an offset in that segment), `O<n>:oooo`, `G:0000:oooo` (offset in `MGRAPHIC.EXE`'s load module; its data segment starts at 13C0h) |
| Kind | `bytes`, `u16`, `str` (one NUL-terminated string), `strs` (Count consecutive strings), `ptrs` (Count near DGROUP pointers to strings), `imm8`, `imm16` |
| Count | elements (`bytes`: the length; `str`: 1) |
| Stride | bytes per element (`-`: the kind's own: 1 for `bytes`, 2 for `u16` and `ptrs`) |
| Max | the longest string allowed, NUL excluded (`str`, `strs`, `ptrs`); `-` otherwise |
| Shape | the check of the data: `-`; `last=FFFFh` (the last word); `groups0=GxS` (G groups of S-byte records, each group ended by a 0 byte, filling the table exactly); `range=a..b` (every element) |
| Readers | DOS listing addresses that read it: an instruction (its operand, or else its function, references the table or its segment word) or a range `X..Y` (one instruction in it does) |
| Writers | DOS listing instructions that write into it (`none` after the scan of `registry.py check`); with writers the file holds only the initial value |
| Source | D0 documents |
| Phase | the consuming phase |

## Registry

| Id | Address | Kind | Count | Stride | Max | Shape | Readers | Writers | Source | Phase |
|---|---|---|---|---|---|---|---|---|---|---|
| CIV_MAIN_COLOUR | DGROUP:1946 | u16 | 8 | - | - | range=0..15 | O5:1A3F, O5:1A6E, O5:1A9D | none | FORMATS 6.1; SPRITES 6.4; SCENES-PLAY 2.3 | D2 (shapes), D6 |
| CIV_SECOND_COLOUR | DGROUP:1956 | u16 | 8 | - | - | range=0..15 | O5:1AC0, R:1AEA:0C70 | none | FORMATS 6.1; SPRITES 6.4; SCENES-PLAY 2.3 | D2 (shapes), D6 |
| BIRTH_CYCLE | [DGROUP:6416]:0000 | bytes | 131 | - | - | groups0=8x3 | O7:1AAB, O7:1AFC | none | FORMATS 6.1; PALETTE 2.6, 4; TIMING 5.5 | D4 |
| BIRTH_SCHEDULE | [DGROUP:6416]:0083 | u16 | 45 | - | - | last=FFFFh | O7:1B54..1B58 | none | FORMATS 6.1; TIMING 5.5 | D4 |
| TITLE_MENU | DGROUP:1AE2 | str | 1 | - | 128 | - | R:01A8:0494 | none | FORMATS 6.1; SCENES 6 | D4 |
| TEXT_TOKENS | DGROUP:30AE | ptrs | 5 | - | 8 | - | R:1F4D:0486, R:1F4D:04C1 | none | FORMATS 6.1, 3.3 | D5 |
| REPORT_CAPTIONS | DGROUP:2FA6 | ptrs | 7 | - | 32 | - | R:1D05:0619 | none | FORMATS 6.1; SCENES-PLAY 0.2 | D7 |
| ICONPG_ADVANCE | [DGROUP:6420]:0000 | bytes | 72 | - | - | - | O8:16DD | none | FORMATS 6.1; SPRITES 8 | D7 |
| ICONPG_UNIT | [DGROUP:6420]:0044 | bytes | 28 | - | - | - | O8:17A9 | none | FORMATS 6.1; SPRITES 8 | D7 |
| ICONPG_TERRAIN | [DGROUP:6420]:0061 | bytes | 12 | - | - | - | O8:17DC | none | FORMATS 6.1; SPRITES 8 | D7 |
| DRV_DEFAULT_PALETTE | G:0000:1410 | bytes | 384 | - | - | range=0..63 | G:0000:00FD, G:0000:0141, G:0000:0199 | none | FORMATS 6.1; DRIVER 3.5; PALETTE 2.1 | area B (OPEN P4) |
| SETUP_DIFFICULTY | DGROUP:3526 | str | 1 | - | 128 | - | O5:003A | none | SCENES 9.1; DOS-PROFILE 3.4 | D5 (D5c) |
| SETUP_COMPETITION | DGROUP:357B | str | 1 | - | 64 | - | O5:012E | none | SCENES 9.2; DOS-PROFILE 3.4 | D5 (D5c) |
| SETUP_CIVS | DGROUP:3595 | str | 1 | - | 32 | - | O5:0163 | none | SCENES 9.2; DOS-PROFILE 3.4 | D5 (D5c) |
| SETUP_TRIBE | DGROUP:35A6 | str | 1 | - | 64 | - | O5:0309 | none | SCENES 9.3; DOS-PROFILE 3.4 | D5 (D5c) |
| SETUP_TRIBE_SEP1 | DGROUP:35BB | str | 1 | - | 8 | - | O5:0345 | none | SCENES 9.3 | D5 (D5c) |
| SETUP_TRIBE_SEP2 | DGROUP:35BE | str | 1 | - | 8 | - | O5:037F | none | SCENES 9.3 | D5 (D5c) |
| SETUP_PLURAL | DGROUP:35C1 | str | 1 | - | 8 | - | O5:054B | none | SCENES 9.3 | D5 (D5c) |
| TRIBE_RECORDS | DGROUP:14E2 | bytes | 928 | - | - | - | O5:0335, O5:036F, O5:04B7, O5:04E0, O5:04FD, O5:051A | R:0403:380E, R:0403:381F, R:0403:3830 | SCENES 9.3; FORMATS 6 | D5 (D5c) |
| NAME_LEADER | DGROUP:53AB | str | 1 | - | 16 | - | O23:0122 | none | SCENES 9.5, 10.4 | D5 (D5d) |
| NAME_TRIBE | DGROUP:53B8 | str | 1 | - | 32 | - | O23:01C5 | none | SCENES 9.4, 10.4 | D5 (D5d) |
| INIT_SECTION | DGROUP:35C3 | str | 1 | - | 8 | - | O5:0691 | none | SCENES 9.6 | D5 (D5d) |
| INIT_SEP | DGROUP:35C9 | str | 1 | - | 4 | - | O5:06DF | none | SCENES 9.6 | D5 (D5d) |
| INIT_BREAK | DGROUP:35CC | str | 1 | - | 4 | - | O5:06F8 | none | SCENES 9.6 | D5 (D5d) |
| INIT_ROADS | DGROUP:35CE | str | 1 | - | 16 | - | O5:0711 | none | SCENES 9.6 | D5 (D5d) |
| ADVANCE_NAMES | DGROUP:04DA | bytes | 1584 | - | - | - | O5:06CF | none | SCENES 9.6; FORMATS 6 | D5 (D5d) |
| CUSTOM_LAND | DGROUP:1B48 | str | 1 | - | 96 | - | R:01A8:0633 | none | SCENES 7.4 | D5 (D5e) |
| CUSTOM_TEMP | DGROUP:1B6F | str | 1 | - | 96 | - | R:01A8:0690 | none | SCENES 7.4 | D5 (D5e) |
| CUSTOM_CLIMATE | DGROUP:1BA0 | str | 1 | - | 96 | - | R:01A8:06ED | none | SCENES 7.4 | D5 (D5e) |
| CUSTOM_AGE | DGROUP:1BC5 | str | 1 | - | 96 | - | R:01A8:074A | none | SCENES 7.4 | D5 (D5e) |
| CUSTOM_HELP_LAND | DGROUP:1B6A | str | 1 | - | 16 | - | R:01A8:0666 | none | SCENES 7.4, 10.3 | D5 (D5e) |
| CUSTOM_HELP_TEMP | DGROUP:1B94 | str | 1 | - | 16 | - | R:01A8:06C3 | none | SCENES 7.4, 10.3 | D5 (D5e) |
| CUSTOM_HELP_CLIMATE | DGROUP:1BBD | str | 1 | - | 16 | - | R:01A8:0720 | none | SCENES 7.4, 10.3 | D5 (D5e) |
| CUSTOM_HELP_AGE | DGROUP:1BFE | str | 1 | - | 16 | - | R:01A8:077D | none | SCENES 7.4, 10.3 | D5 (D5e) |
| HELP_PREFIX | DGROUP:34B0 | str | 1 | - | 4 | - | O4:0006 | none | SCENES 10.3 | D5 (D5e) |
| FAME_TEXT | DGROUP:33BE | strs | 18 | - | 32 | - | O3:0106, O3:01F3, O3:0388, O3:0444 | none | SCENES 7.5; SCENES-PLAY 7.17 | D5 (D5f) |
| FAME_RANKS | DGROUP:33A2 | ptrs | 5 | - | 8 | - | O3:029F, O11:01D0 | none | SCENES 7.5; SCENES 7.2 | D5 (D5f), SL |
| FAME_POP | DGROUP:2FD2 | strs | 3 | - | 8 | - | R:1DC4:0367, R:1DC4:03BC | none | SCENES 7.5 | D5 (D5f) |
| SL_LOAD_HEAD | DGROUP:41B0 | str | 1 | - | 32 | - | O11:0029 | none | SCENES 7.2 | SL |
| SL_TEXT | DGROUP:41D7 | strs | 7 | - | 16 | - | O11:0191, O11:01E0, O11:0266, O11:0286, O11:02C7, O11:02CC, O11:02D1 | none | SCENES 7.2 | SL |
| SL_SAVE_HEAD | DGROUP:41F4 | str | 1 | - | 32 | - | O11:0391 | none | SCENES 7.2 | SL |
| UNIT_END_TURN | DGROUP:207F | strs | 3 | - | 16 | - | R:0403:4096, R:0403:40AD, R:0403:40C4 | none | SCENES-PLAY 5.3 | D6 (D6e) |
| UNIT_VETERAN | DGROUP:20A3 | str | 1 | - | 16 | - | R:0403:4150 | none | SCENES-PLAY 5.3 | D6 (D6e) |
| UNIT_MORE | DGROUP:20F1 | str | 1 | - | 4 | - | R:0403:44F1 | none | SCENES-PLAY 5.3 | D6 (D6e) |
| MENU_TITLES | DGROUP:1D6F | strs | 5 | - | 12 | - | R:0238:1011, R:0238:1029, R:0238:1041, R:0238:1059, R:0238:1071 | none | SCENES-PLAY 5.1 | D6 (D6f) |
| MENU_GAME | DGROUP:2BD4 | str | 1 | - | 96 | - | R:1C84:00C0 | none | SCENES 10.2 | D6 (D6f) |
| MENU_OPTIONS | DGROUP:2C3E | str | 1 | - | 112 | - | R:1C84:013B | none | SCENES 10.2 | D6 (D6f) |
| MENU_ADVISORS | DGROUP:2DD6 | strs | 2 | - | 96 | - | R:1C84:061B, R:1C84:062B | none | SCENES 10.2 | D6 (D6f) |
| MENU_WORLD | DGROUP:2E5D | strs | 2 | - | 80 | - | R:1C84:06F8, R:1C84:0708 | none | SCENES 10.2 | D6 (D6f) |
| MENU_PEDIA | DGROUP:2ED1 | strs | 2 | - | 96 | - | R:1C84:07B5, R:1C84:07C5 | none | SCENES 10.2 | D6 (D6f) |
| MENU_ORDERS | DGROUP:2CA9 | strs | 19 | - | 32 | - | R:1C84:023D, R:1C84:05B6 | none | SCENES 10.2 | D6 (D6fS-b) |
| MENU_REPLAY | DGROUP:2C30 | str | 1 | - | 16 | - | R:1C84:00D8 | none | SCENES 10.2 | D6 (D6fS-b) |
| TERRAIN_BY_COLOUR | DGROUP:2BA6 | u16 | 16 | - | - | - | R:1C84:0351, R:1C84:03D0, R:1AEA:1363 | none | FORMATS 6.1; SCENES 10.2 | D6 (D6fS-b) |
| TERRAIN_NAMES | DGROUP:0282 | bytes | 12 | 19 | - | - | R:1C84:0355, R:1C84:03D4, R:0403:42F7 | none | FORMATS 6.1; SCENES 10.2 | D6 (D6fS-b) |
| PALACE_WIDTHS | DGROUP:4B2C | u16 | 5 | - | - | - | O17:04F1, O17:05E4, O17:0933, O17:0979, O17:0A61, O17:0AF6 | none | SCENES-PLAY 7.8 | D7 (D7j) |
| PALACE_YOFS | DGROUP:4B36 | bytes | 75 | - | - | range=0..3 | O17:0E74 | none | SCENES-PLAY 7.8 | D7 (D7j) |
| PALACE_PROMPT | DGROUP:4AF0 | str | 1 | - | 48 | - | O17:0130 | none | SCENES-PLAY 7.8 | D7 (D7j) |
| PALACE_SELECT | DGROUP:4B13 | str | 1 | - | 32 | - | O17:0411 | none | SCENES-PLAY 7.8 | D7 (D7j) |
| CITY_POP | DGROUP:24EC | strs | 2 | - | 8 | - | R:0D12:0533, R:0D12:054F | none | SCENES-PLAY 7.1 | D7 (D7d) |
| CITY_TABS | DGROUP:25EA | strs | 5 | - | 8 | - | R:0D12:26BB, R:0D12:26DB, R:0D12:26FB, R:0D12:271B, R:0D12:32A1 | none | SCENES-PLAY 7.1 | D7 (D7d) |
| CITY_PANEL | DGROUP:262A | strs | 10 | - | 16 | - | R:0D12:3CC9, R:0D12:3E17, R:0D12:3E1D, R:0D12:3E3D, R:0D12:3FC9, R:0D12:4104, R:0D12:4645, R:0D12:4708, R:0D12:4862, R:0D12:4882 | none | SCENES-PLAY 7.1 | D7 (D7d) |
| CITY_MAP_DX | DGROUP:280C | bytes | 4 | - | - | - | R:0D12:7374 | none | SCENES-PLAY 7.1 | D7 (D7d) |
| CITY_MAP_DY | DGROUP:2810 | bytes | 4 | - | - | - | R:0D12:7390 | none | SCENES-PLAY 7.1 | D7 (D7d) |
| CITY_NONE | DGROUP:2913 | str | 1 | - | 8 | - | R:1459:08CF | none | SCENES-PLAY 7.1 | D7 (D7d) |
| IMPR_RECORDS | DGROUP:0BB8 | bytes | 1350 | - | - | - | R:0D12:3B01, R:0D12:3C0A | none | SCENES-PLAY 7.1; FORMATS 6 | D7 (D7d) |
| SPACE_PARTS | DGROUP:4BD0 | bytes | 260 | - | - | - | O18:005D, O18:0061, O18:0065, O18:0069, O18:04F7, O18:1241, O18:13E3, O18:142F, O18:14AE, O18:14DE, O18:150E, O18:1515 | none | SCENES-PLAY 7.16 | D7 (D7l) |
| SPACE_LAUNCH | DGROUP:4D8E | str | 1 | - | 8 | - | O18:0AB3 | none | SCENES-PLAY 7.16 | D7 (D7l) |
| REPLAY_MENU | DGROUP:3FB0 | str | 1 | - | 96 | - | O9:0016 | none | SCENES-PLAY 7.17 | D7 (D7m) |
| SPACE_SECTION | DGROUP:32F2 | str | 1 | - | 8 | - | O2:0E63 | none | SCENES-PLAY 7.16; TIMING 5.7 | D7 (D7l2) |
| SPACE2_SECTION | DGROUP:32F9 | str | 1 | - | 8 | - | O2:0E68 | none | SCENES-PLAY 7.16; TIMING 5.7 | D7 (D7l2) |
| BOX_RATES | DGROUP:1F9F | strs | 6 | - | 32 | - | R:0403:35CE, R:0403:3622, R:0403:3660, R:0403:36B9, R:0403:370E, R:0403:374B | none | SCENES-PLAY 7.20 | D6 (D6fSc) |
| BOX_QUIT | DGROUP:2037 | str | 1 | - | 64 | - | R:0403:38B6 | none | SCENES 10.2 | D6 (D6fSc) |
| BOX_REV_SECTION | DGROUP:1F6A | str | 1 | - | 8 | - | R:0403:3547 | none | SCENES-PLAY 7.10; FORMATS 3.3 | D6 (D6fSc) |
| WONDER_RECTS | [DGROUP:6444]:0000 | u16 | 88 | - | - | - | O19:097F, O19:10E2, O19:160D | O19:1631, O19:1641 | FORMATS 6.1; SCENES-PLAY 7.2 | D7 (D7e) |
| DIR_DX | DGROUP:1882 | u16 | 9 | - | - | - | O19:0A4C, O19:0B2F | none | SCENES-PLAY 7.2 | D7 (D7e) |
| DIR_DY | DGROUP:18E4 | u16 | 9 | - | - | - | O19:0A3E, O19:0A5B, O19:0A8E, O19:0B21, O19:0B3E, O19:0B7C | none | SCENES-PLAY 7.2 | D7 (D7e) |
| CITY_ANIM_DX | DGROUP:4F42 | u16 | 4 | - | - | - | O19:1A2D, O19:1BEA | none | SCENES-PLAY 7.3 | D7 (D7e) |
| CITY_ANIM_DY | DGROUP:4F4A | u16 | 4 | - | - | - | O19:1A5C, O19:1C1E | none | SCENES-PLAY 7.3 | D7 (D7e) |
| LEADER_FONT | [DGROUP:640A]:0000 | bytes | 16 | - | - | range=0..2 | O6:1815 | none | SCENES-PLAY 7.9; FORMATS 6.1 | D7 (D7k) |
| LEADER_FACE_X | [DGROUP:640A]:0010 | u16 | 28 | - | - | - | O6:249F, O6:24AA, O9:117B, O9:1186 | none | SCENES-PLAY 7.9, 7.17; FORMATS 6.1 | D7 (D7k, D7n) |
| LEADER_FACE_Y | [DGROUP:640A]:0048 | u16 | 28 | - | - | - | O6:24B2, O6:24BD, O9:1192, O9:119D | none | SCENES-PLAY 7.9, 7.17; FORMATS 6.1 | D7 (D7k, D7n) |
| LEADER_ATTEND_X | [DGROUP:640A]:0080 | u16 | 56 | - | - | - | O6:240D, O6:2417 | none | SCENES-PLAY 7.9; FORMATS 6.1 | D7 (D7k) |
| LEADER_ATTEND_Y | [DGROUP:640A]:00F0 | u16 | 56 | - | - | - | O6:2422, O6:2433 | none | SCENES-PLAY 7.9; FORMATS 6.1 | D7 (D7k) |
| LEADER_PORTRAIT | DGROUP:3938 | bytes | 16 | - | - | range=0..13 | O6:1EE5 | none | SCENES-PLAY 7.9 | D7 (D7k) |
| LEADER_SLOT_X | DGROUP:3AFE | u16 | 4 | - | - | - | O6:2231, O6:23E7 | none | SCENES-PLAY 7.9 | D7 (D7k) |
| PROD_TEXTS | DGROUP:222A | strs | 3 | - | 32 | - | R:0ADE:045D, R:0ADE:0478, R:0ADE:050E | none | SCENES-PLAY 7.12 | D7 (D7f) |
| PROD_MORE | DGROUP:225F | strs | 2 | - | 16 | - | R:0ADE:090A, R:0ADE:0931 | none | SCENES-PLAY 7.12 | D7 (D7f) |
| HELP_AVAILABLE | DGROUP:2FBD | str | 1 | - | 24 | - | R:1D05:0783 | none | SCENES-PLAY 7.12 | D7 (D7f) |
| BUY_TEXTS | DGROUP:266E | strs | 6 | - | 24 | - | R:0D12:4CDF, R:0D12:4D46, R:0D12:4D77, R:0D12:4DAE, R:0D12:4DE2, R:0D12:4E08 | none | SCENES-PLAY 7.1 | D7 (D7f) |
| STACK_VETERAN | DGROUP:2224 | str | 1 | - | 8 | - | R:0866:205A | none | SCENES-PLAY 7.19 | D7 (D7f) |
| CITY_NAME_PROMPT | DGROUP:539E | str | 1 | - | 16 | - | O23:0051 | none | SCENES 10.4 | D7 (D7f) |
| UNIT_RECORDS | DGROUP:112A | bytes | 952 | - | - | - | R:0866:2043 | none | SCENES-PLAY 7.19; FORMATS 6 | D7 (D7f) |
| REPORT_SUFFIX | DGROUP:2FB4 | str | 1 | - | 8 | - | R:1D05:0630 | none | SCENES-PLAY 0.2 | D7 (D7g) |
| SCIENCE_TEXTS | DGROUP:2327 | strs | 10 | - | 40 | - | R:0ADE:1A18, R:0ADE:1A3E, R:0ADE:1A62, R:0ADE:1A9A, R:0ADE:1ADE, R:0ADE:1B3D, R:0ADE:1B60, R:0ADE:1B65, R:0ADE:1B75, R:0ADE:1C28 | none | SCENES-PLAY 7.11 | D7 (D7g) |
| PEDIA_TEXTS | DGROUP:3C8E | strs | 72 | - | 42 | - | O8:008A, O8:073B, O8:07D6, O8:156B | none | SCENES-PLAY 7.13 | D7 (D7h) |
| PEDIA_CONCEPTS | DGROUP:3C64 | ptrs | 21 | - | 16 | - | O8:030F, O8:0B94 | none | SCENES-PLAY 7.13 | D7 (D7h) |
| TERRAIN_RECORDS | DGROUP:0282 | bytes | 24 | 19 | - | - | O8:02B2, O8:0B6E, O8:11E3, O8:1202 | none | SCENES-PLAY 7.13; FORMATS 6 | D7 (D7h) |
| TERRAIN_RULES | DGROUP:044A | bytes | 12 | 12 | - | - | O8:1221, O8:1285, O8:1335, O8:13A0 | none | SCENES-PLAY 7.13; FORMATS 6 | D7 (D7h) |
| NEWS_ORNAMENT | DGROUP:5147 | strs | 2 | - | 8 | - | O21:023E, O21:0255 | none | SCENES-PLAY 7.7 | D7 (D7i) |
| NEWS_PRESS | DGROUP:5181 | str | 1 | - | 32 | - | O21:03F3 | none | SCENES-PLAY 7.7 | D7 (D7i) |
| DISCOVERY_TEXTS | DGROUP:22CC | strs | 5 | - | 32 | - | R:0ADE:17B4, R:0ADE:17B9, R:0ADE:17C9, R:0ADE:17F7, R:0ADE:182C | none | SCENES-PLAY 7.11 | D7 (D7i) |
| QUIZ_TEXTS | DGROUP:4A61 | strs | 2 | - | 56 | - | O16:0167, O16:0181 | none | SCENES-PLAY 7.15 | D7 (D7i) |
| NOTE_TITLE | DGROUP:34E7 | str | 1 | - | 32 | - | O4:0369 | none | SCENES-PLAY 7.18 | D7 (D7g2) |
| SALE_TEXTS | DGROUP:26AD | strs | 3 | - | 32 | - | R:0D12:57A5, R:0D12:57CC, R:0D12:580A | none | SCENES-PLAY 7.1 | D7 (D7g2) |

## Notes

* `TRIBE_RECORDS` (extension D5c) is the 16 tribe records of 58 (3Ah) bytes, two groups of 8 (slot 0 and 8
  unused): +00h leader name, +10h plural name (empty: the name at +20h with SETUP_PLURAL appended,
  O5:052E..0558), +20h name (the tribe page's rows, O5:032F..039A), +36h and +38h the tune and sound
  words (FORMATS 6.1); the writers R:0403:380E, 381F, 3830 (play) store the words +30h, +32h, +34h, which
  the setup does not read: it reads only the three names (+00h..2Fh), which nothing writes.
* The city rows (extension D7d) are what the DOS city screen R:0D12:0045 reads: its title, tab, panel and
  route texts (`CITY_POP`, `CITY_TABS`, `CITY_PANEL`), the 2 x 2 dot offsets of its MAP tab (R:0D12:72B7), the home
  name of a unit with no home (`CITY_NONE`, R:1459:08C6) and the improvement records (`IMPR_RECORDS`: 45 records of
  1Eh bytes, the name at +00h; record i is building bit i for i < 24 and wonder i - 23 after; the production name
  R:0D12:3EAD reads record n - 1 through DGROUP:0B9A + 1Eh n). The table ends where the wonder table DGROUP:10FE
  starts.
* `ICONPG_ADVANCE` is 72 bytes because the search O8:16C4 runs 4 bytes into the unit table
  (SPRITES 8): the registry describes the bytes the DOS routine reads, so the two ranges overlap.
* The far rows (`[DGROUP:6416]`, `[DGROUP:6420]`) are reached through a relocated segment word; the
  activation checks that the word is a relocation target of the root (`pdos_image_is_reloc`) and that
  the referenced range lies in the far data segments. Their writer scan is best effort: the listing
  does not track the segment register of `es:` writes, so `registry.py check` prints the candidate
  writes it finds and the row keeps `none` only after they are read by hand.
* Readers are checked against the listing as references (an operand equal to an address in the table,
  or to its segment word); `registry.py check` prints every comparison.
* `PALACE_WIDTHS` and `PALACE_YOFS` (extension D7j) are the palace composer's piece widths (W[0..4]) and y
  offsets (15 per level, 5 per variant, one per piece type; DrawPiece O17:0E2F). The preview of the
  improvement (O17:04E6, 0520, 05CD, 05EF, 0627, 0652, 068E) reads the same offsets through the bases
  DGROUP:4B31..4B35 with an index of at least 5 (5 k for the box k, 1..3), so its operand lies below the table;
  it is not listed as a reader.
* `SPACE_PARTS` (extension D7l) is the spaceship's ten part records of 26 (1Ah) bytes: the name (16 bytes, NUL
  padded), the mass, then the shape's rectangle x, y, w, h in DOCKER.PIC (O18:0055..0089 cuts the shapes with G#2;
  O18:04EF..050E sums the masses).  O18:1241 takes a record's address as an immediate (the name of a part type in
  the "No further" box).  The Windows records g_spaceshipPartSprites 1420:12AA (10 bytes: the mass, then left, top,
  width, height) hold the same masses with rectangles 1.5 times larger (OPEN L15, compared in ext-D7l-record.md).
* `MENU_ORDERS`, `MENU_REPLAY`, `TERRAIN_BY_COLOUR` and `TERRAIN_NAMES` (extension D6fS-b) are what the ORDERS
  menu (R:1C84:01D8..05E6) and the GAME menu's View Replay row (R:1C84:00D0..00E0) concatenate: the nineteen ORDERS
  strings in the order of their uses, View Replay's row, the terrain index of each map colour (-1 for a colour
  without terrain) and the twelve terrain names in slots of 13h bytes (R:1C84:034A..035D, 03C9..03DC: DGROUP:0282 +
  13h * [2BA6 + 2 colour]).  R:1AEA:1363 (the terrain of a square) and R:0403:42F7 read them too.
* The D7f rows (extension D7f, `present/dos/pdos_rdlg.c`) are the DOS texts of the boxes that replace the
  core's list, entry, production, buy and unit stack dialogs (decision 15): the production menu's header ("What
  shall we build in " + the city name + its second string) and a unit row's ", ADM:" (`PROD_TEXTS`,
  R:0ADE:0421), its two "more..." rows (`PROD_MORE`, page 1 and page 2), the menu box's help line
  (`HELP_AVAILABLE`, R:1D05:0475's help branch R:1D05:075B..0796), the buy question's lines (`BUY_TEXTS`, the city
  screen's buy routine: cost, treasury, the civil disorder note and the two items), the unit stack popup's
  veteran suffix (`STACK_VETERAN`) and the unit records it names its rows from (`UNIT_RECORDS`: 28 records of
  22h bytes, the name at +00h; R:0866:203D..2043 indexes them by 22h times the unit type), and the city name
  prompt of the text entry O23:0000 (`CITY_NAME_PROMPT`). The core's own texts stay where no DOS text pairs
  with them (the production list's rows, Find City's list, the entry's other prompts).
* The D7g rows (extension D7g, `present/dos/pdos_ui.c`, `present/dos/pdos_reskin.c`): the report header's suffix
  " report:" that R:1D05:0613..063D appends to the captions 0..2 (`REPORT_SUFFIX`, after `REPORT_CAPTIONS`), and
  the ten strings of the science advisor's recommendation and of the research choice (`SCIENCE_TEXTS`, in their
  order in DGROUP: the recommendation's opening lines, the line feed after the advance, "So we can build:" and
  the separators after a unit and after an improvement, R:0ADE:1A18..1AEB; the research choice's first line, its
  two words for the wise men, its last two lines and the separator after an advance, R:0ADE:1B3D..1C30).
* The D7i rows (extension D7i, `present/dos/pdos_scn_news.c`): the newspaper's two masthead ornaments that
  O21:022C..025E draws beside a name narrower than 200 pixels (`NEWS_ORNAMENT`) and its "Press any key" box
  (`NEWS_PRESS`, O21:03E8..03F7), the five words of the discovery's sentence (`DISCOVERY_TEXTS`, in their order in
  DGROUP: the two words for the scientists, the middle with its two line feeds, the separator before a count and
  the end, R:0ADE:178C..1849) and the quiz's two question lines (`QUIZ_TEXTS`, O16:015D..0185). The names in the
  sentence (the adjective, the advance) and the quiz's title, pages and answers stay the core's.
* `NOTE_TITLE` (extension D7g2, `present/dos/pdos_rdlg.c`) is the title that the instant advice O4:02D3 centres at
  (160, 19) (O4:0369). The error note O4:03AA centres its own copy at DGROUP:350B (O4:0438); the listing gives both
  the same text, and the renderer draws `NOTE_TITLE` for both forms.
* `SALE_TEXTS` (extension D7g2, `present/dos/pdos_reskin.c` `pdos_r_sale_text`) are the city screen's sale question's
  three parts (R:0D12:57A5..5817): the first line and "your ", the word before the price, and the end with the rows
  No. and Yes.; the building's name and the price go between them. R:0D12:5834 asks it at (128, 80) in font 1.
* `REPLAY_MENU` (extension D7m) is the replay question that O9:000E..001F passes to R:0238:001E (a header
  line, then the items, each after one space). The core asks its own words through D5b's box; the end-of-game
  renderer compares the two (`menu_same`, `menu_differs`) and draws nothing of its own.
* `SPACE_SECTION` and `SPACE2_SECTION` (extension D7l2) are the `KING.TXT` section names of the spaceship arrival
  O2:0BD7: the first for the human's ship (O2:0E5B..0E66: the arriving civ equal to DGROUP:D7EE), the second for another
  civilization's (O2:0E68); R:1F4D:01AD loads the section into DGROUP:BA06.
* `BOX_RATES`, `BOX_QUIT` and `BOX_REV_SECTION` (extension D6fSc) are the DOS texts of the boxes the A canvas pairs
  by their call site (ext-D6fSc-record.md): the tax and luxuries rate menus' six strings (R:0403:35CE..374B: each
  header, then a row's two texts between its two numbers, R:2045:1F6A's), the quit question with its rows, which
  GAME's QUIT, Retire and the Alt+Q key reach (R:0403:38B6, R:1C84:01A3..01B7, R:0403:3B27), and the name of the
  KING.TXT section that R:0403:3547 reads through R:1F4D:044F for the revolution question.
* The Civilopedia rows (extension D7h, `present/dos/pdos_scn_pedia.c`) are what the overlay O8 reads: its 72
  strings (`PEDIA_TEXTS`, DGROUP:3C8E..3FA3: the index's title, EXIT, MORE and the sort's bounds, the picture files'
  names, the category labels and the detail lines' parts), the 21 game concepts (`PEDIA_CONCEPTS`, near pointers),
  the 24 terrain records of 13h bytes (`TERRAIN_RECORDS`: the name at +00h, movement +0Ch, defence +0Dh, food
  +0Eh, shields +0Fh, trade +10h; records 12..23 are the specials the entry page lists after the terrain,
  O8:11CA..155D; the first 12 are D6fS-b's `TERRAIN_NAMES`, so the two rows overlap) and the 12 terrain rules of
  0Ch bytes (`TERRAIN_RULES`: the irrigation word at +00h and the mining word at +04h, below -1 when the work
  adds - w - 1). The advance, improvement and unit records are `ADVANCE_NAMES`, `IMPR_RECORDS` and
  `UNIT_RECORDS`; the picture cells `ICONPG_ADVANCE`, `ICONPG_UNIT` and `ICONPG_TERRAIN`.
* The city view rows (extension D7e). `WONDER_RECTS` is the far table of the wonders' rectangles in WONDERS.PIC and
  WONDERS2.PIC: 22 entries of 8 bytes (entry 0 unused), x, y, then the right and bottom edges as the file holds them;
  O19:1606 (called by the loader O19:137F) converts entries 1..21 in place to a width and a height (x2 - x1 + 1,
  y2 - y1 + 1) when entry 1's third word is above 300 (O19:1611), so its two writers (O19:1631, O19:1641) leave only
  the initial value in the file; the readers O19:097F (the big wonders' places, x and y) and O19:10E2 (a wonder's
  height above its cell) index it by 8 w with w at most 21 (the grid's values 40h..55h). `DIR_DX` and `DIR_DY` are
  the eight direction steps (index 1..8; index 0 the centre) of the city view's road mask and road post-pass
  (O19:0A2F..0B88); many other routines read them (O2, O4, O5, O7 and others), not listed. `CITY_ANIM_DX` and
  `CITY_ANIM_DY` are the four figures' offsets of the civil disorder (O19:18C1) and the celebration (O19:1AE1; its
  x offset taken 3/2 times, O19:1BE7..1BF1).
* The leader rows (extension D7k) are what the leader screen O6:1D2B..2512 reads. `LEADER_FONT` is the first 16
  bytes of the far segment `[DGROUP:640A]` (B 10.1, OB8): byte b of tribe t (DGROUP:D7F4[n], O6:180F..1815) makes the
  leader font 8 + b, 10 replaced by 3 (O6:181B..1826). The rest of the segment is the throne-room animation table of
  O6:2362 (SCENES-PLAY Open 8, FORMATS 6.1): `LEADER_FACE_X` / `_Y`, two words per portrait p at 10h + 4p and 48h + 4p
  (O6:2495..24C2; p = `LEADER_PORTRAIT`[t], 0..13, the fourteen KING00..13 files the same index names, O6:1F18..1F2A),
  and `LEADER_ATTEND_X` / `_Y`, two words per animation style and attendant variant at 80h + 10h s + 4v and F0h + 10h s
  + 4v (O6:23F3..2433; s 0..6 from O6:2380..23AF, v = (slot + civ) & 3). The four tables abut (10h + 38h = 48h, 48h +
  38h = 80h, 80h + 70h = F0h); the lengths are their readers' index ranges, not the next segment's start (BRIEF-d7
  ruling 9). `LEADER_PORTRAIT` (16 tribes, O6:1EDC..1EE5) ends where the emissary text DGROUP:3948 starts (O6:170D);
  `LEADER_SLOT_X` (the attendant slots s < (rank + 1) / 2, at most 4: O6:2244..2256) ends where the throne-room
  picture name DGROUP:3B06 starts (O6:21C2). Extension D7n: the conquered leader O9:0F79 reads `LEADER_FACE_X` and
  `_Y` too, for its mouths' place (O9:1171..11A2: x = 5Ah + (X[2p] - B4h) - X[2p + 1], y = (Y[2p] - 40h) -
  Y[2p + 1]), through the far words [DGROUP:642E] (X) and [DGROUP:6430] (Y) instead of [640A]; the three words are
  relocation entries holding the same segment in the load module (26FAh; no writer in the listings, as OPEN L1's
  [640A]), so the rows keep their single location and list the O9 readers beside O6's.

<!-- Independent adversarial review of claude/docs/x64-port-scaling-dos-prompt.md (extension phase X0),
     by a separate read-only reviewer agent, 2026-10-10 17:05..17:30 UTC. Stored verbatim; the session's
     resolutions are in ext-X0-acceptance.md. Scratch scripts it names are not part of the repository. -->

# X0 adversarial review: civ64 extension prompt (`claude/docs/x64-port-scaling-dos-prompt.md`)

**How I worked.** I read the whole extension prompt, then the base prompt sections 1, 2, 4, 5.0, 5.1, 5.5, 6 (rule 13), 7, 8, 9, 10 and 11. In the repository I read:
- STATUS.md, twice. The running X0 session added the "Extension track" section and the phase R text while I was reviewing.
- DESIGN.md sections 5 and 6, FIDELITY.md F90..F98, RUNNING.md and the FEATURES.md header.
- `host.h`, `host_sync.c`, `gdi_pal.c`, `clock.c`/`queue.c` (the calls to the present and sync functions), `vm.h`/`vm.c` `fr_enter`, `host_win32.c`, `civ64_main.c`, `civ64_start.c`, `harness.c`, `host_headless.c`, `test_host_win32.c`, `build.cmd`, `test.cmd`, `gate3b.py` and `scenarios.py` (as far as they compare hashes).

Evidence labels used below:
- **showfunc**: the output of `showfunc.py`.
- **doc**: a file under `claude/docs`.
- **src**: a port source file and line.
- **DOS file**: my own read-only scripts on `C:\Projects\Civ1RE\dos`, run with capstone 5.0.7.
- **port output**: `build/harness/game/p4-*/pictures.txt`.

Scratch scripts are in `...\scratchpad\x0-review\`. Nothing in the repository, `dos/` or `original/` was modified, and nothing from them was executed.

---

## A. Facts

### A1. Windows facts (extension section 3, 5.6 I5, 5.8, 8)

| Fact | Result | Evidence |
|---|---|---|
| MapLogicalPointToPort 1220:0F2F; dialog → ScaleLogicalX/Y; city-tile mode → map transform; `(x-200)*2-g_mapScrollX`, `(y-8)*2-g_mapScrollY` into the map port | **Confirmed, two corrections.** (1) The status window case is `0 <= x < 200`; a negative x is "not drawable" (returns 0). (2) In the dialog + `g_cityTileDrawMode` case, drawing still targets the dialog port (`g_curWindowPort = g_currentDialogPort`, returns 3), not the map port. | showfunc 1220:0FDE..0FEF, 0F4A..0FD5; graphics.md 4.7 |
| ScaleLogicalX/Y 11E8:0D81/0DA8 = `(long)v*160/100`, truncated | Confirmed: `movsx`/`imul`/`idiv` (32-bit signed, truncates toward zero) | showfunc |
| g_cityTileDrawMode 1260:002C; g_egaToSystemColor 12D8:45BE | Confirmed | showfunc comments; palette-pictures.md 2.8 |
| Dialog 148 opened at 16 call sites | Confirmed: 16 `push 0x94` before a `call GR_DialogOpen` | asm grep; architecture.md 4.1 |
| 199 CvPc pictures with the listed sizes | Confirmed. 128 is 1024x320; 129..135, 140..143 are 512x320; 136 is 502x145 (the logo); 137 is 320x200; 144 is 640x400; 200 is 1472x400; 202 is 243x116; 400..406 are 939x320; 500..513, 1013, 1014 are 427x320; 1100..1166 are 178x132; 1200..1227 are 215x100; 5000..5006 are 300x115; the rest vary. Note: "5555..5600" is a sparse id set, not a full range. | port output (decoder sizes; model); startup-audits.md:453 gives 1472x400 |
| GR_PicRead 10B8:079D, LoadGifPicture 10B8:11BC, PicDecompress 10B8:158C, GenerateWorldMap 1028:0000 (picture 137 used as data) | Confirmed | showfunc; palette-pictures.md:488, 766 |
| ExtractGameSpriteShapes 10E8:231F, ExtractPictureTile2x 11E8:097C (doubled, xBase 0 or 640); Tile1x/TileExtract; device x >= 1152 is Windows-only (inferred) | Confirmed. Tile1x is at 10E8:33B9, TileExtract at 11A8:05C7. | showfunc; graphics.md 4.9 |
| Movies: Intro 13D0:0000 with 29 items and the title menu at frame 1260; Birth 13D8:0000 with 78 items, frames 1000..11500, 44 text items; About 1230:0000 | Confirmed (About has 63 items) | graphics.md 4.14.3 |
| RunIntroAndTitleMenu 11E0:0000; BirthMovieCallback 11E0:091E; BeginWorldCreation 1108:01BC; g_movieSkipRequested 13E0:001E | Confirmed | showfunc; graphics.md 4.14.4 |
| DrawMapTile 1110:04D0, ComputeTileAppearanceKey 1118:04B4, RenderTileFromKey 1118:0000, g_tileCache 1420:A2EA (250 entries) | Confirmed | showfunc; graphics.md 2.6 |
| DrawTilesToPort 1208:1866: mode 1 dissolve consumes the RNG | Confirmed: `RandomBelow` pair swaps on the shared stream. Also: it draws into `g_mapOffscreenPort` and then blits; mode 1 blits square by square. | showfunc; cross-version.md row 46 exists |
| DrawUnitAt 1110:0FF6, DrawCityLabels 1208:1F64, DrawSmTiles 1210:09B4, RedrawStatusWindow 1218:0801, DrawUnitInfoPanel 11F0:468C | Confirmed | showfunc |
| CyclePaletteColors 1208:22B7 rotates god entries 64..71 on the 200 ms timer | Confirmed (system 74..81). SetTimer 1/200 ms is at 1208:0E7B. It calls `AnimatePalette(0, 236)`, so a full re-present about every 220 ms. | showfunc |
| MenuZ 1220:0156, ShowTextDialog 1220:00D2; the 100 ms timer drives AnimateLeaderPortrait (R2) | Confirmed (AnimateLeaderPortrait is 1160:26EF, called at 1220:12CD) | showfunc; findings R2 |
| RunNewGameSetup 10E8:0000 uses picture 141 at base 16; CustomizeWorldDialog 1108:0243 uses picture 140; dialogs 139/148/143; 108 FEATURES rows | Confirmed | palette-pictures.md:117, 756; FEATURES/STATUS |
| **I5**: "PollMouseClick (1108:0000) stores g_clickX/Y as signed lParam*10/16 (stores at 1038:0CB6/0CCE)" | **Corrected.** PollMouseClick's stores are at **1108:017A/018F**: 16-bit `imul ax,10; cwd; idiv 16`, signed, only for a click in the current dialog. A click in the map window passes the raw client position. 1038:0CB6/0CCE are inside **WaitForKeyOrClick (1038:0C1D)**, which computes `(WORD)(x*10)>>4` unsigned. The d = ⌈16L/10⌉ rule still holds for both. | showfunc 1108:0169..018F, 1038:0CB6..0CDA; platform.md:794 |
| "WaitForKeyOrClick … `>>4` (platform.md; Q86)" | platform.md is correct. **Q86 is the wrong citation**: Q86 is GetScreenTextWidth's `*10/16` text centring. | open-questions.md:242 |
| 5.8: WdwMapProc 1208:0054; ShowWorldMap 1188:013F, command 504, scale 6/32; direction cursors 0x88..0x8F | Confirmed | showfunc; resources.md; platform.md:189 |
| 5.8: "whole 32x32 squares at the view origin" | **Imprecise.** `g_mapScrollX/Y` (1408:00C6/00C4) are pixel offsets inside the first column and row. Scrolling shifts the image with a screen-to-screen BlitDCRect and redraws only the exposed strip. There is a known bug at 1208:1696 when an offset is non-zero. | world.md:153, 751; showfunc 1208:08D8 |
| 8: GetPortPixelIndex 1070:127A; sprite-sheet key row 399; g_randSeed 1420:4EE0; CopyPortToWindow 10D0:0854 | Confirmed | showfunc; graphics.md 4.9 step 4 |
| ACCELERATOR 128 has 24 entries; 16 cursors | Confirmed (no accelerator uses Shift or Alt) | resources.md |

### A2. DOS facts (section 3), from my read-only scripts on `dos/`

| Fact | Result |
|---|---|
| 176 files in a flat folder: 7 EXE, 106 PIC, 38 PAL, 13 TXT, 1 CV, 5 CVL, 2 MAP, 2 SVE, 1 DTA, 1 ME | Confirmed |
| CIV.EXE 305,030 bytes / 22de2748…; CIV_UNP 340,791 / aa63aa39…; MGRAPHIC 7,142 / bf8907e9…; FONTS.CV 19,123 / c07a501f…; EGRAPHIC fd129cbd…; TGRAPHIC 7da36315…; MISC.EXE 980 bytes / 95b18daf… | Confirmed (UNP.EXE is 20,106 bytes / 9c2bb596…) |
| CIV.EXE is MZ with "Packed file is corrupt" | Confirmed (string at 172,847). Also the EXEPACK header at load-module offset 0x2A020: `RB` signature, real CS:IP 2045:2E7F, SS:SP 398D:0800, dest_len 0x31B4 paragraphs = 203,584 bytes. CIV.EXE has 0 header relocations. |
| CIV.EXE's load module ends at 177,951; 127,079 bytes follow, identical to the tail after CIV_UNP's load module | Confirmed. The tail includes 225 zero bytes before the first overlay. |
| CIV_UNP header: 10,128 bytes (633 paragraphs), 2,525 relocations, load module end 213,712, CS:IP 2045:2E7F, SS:SP 398D:0800 | Confirmed |
| **EXEPACK decoder reproduces CIV_UNP** (D-1, 7.6) | **Feasibility proven.** A straightforward backward EXEPACK decoder (437 commands) gives a load module **byte-identical** to CIV_UNP's (203,584 bytes, 0 differences). The packed relocation table gives the **same 2,525 relocations in the same order**. (scratch `exepack.py`) |
| MS C run-time string; "Overlay not found"; "Overlay Manager stack overflow" | Confirmed (CIV_UNP 186,280; 211,446; 211,481) |
| 23 MZ overlays numbered 1..23; the first at 213,937 | Confirmed. The last ends exactly at EOF. Header sizes are 512 or 1024; each has 34..246 relocations. |
| PIT `mov al,36h; out 43h,al` at load-module 0x23, 0x5C, 0x258; INT 08h vector read/set at 0x34, 0x44, 0x6A | Confirmed. 0x34 is INT 21h/35h AL=8 (get), 0x44 is 25h (set), 0x6A restores. **New (DOS listing; interpretation inferred):** 0x23/0x5C write divisor 0 (65,536). 0x258 writes a *variable* divisor from [0x46]. Start-up code at 0x276 measures 16 periods through a routine at 0x30B. Every 20 ticks the code at 0x215 re-measures port 0x3DA (VGA retrace) and reprograms the PIT. The handler at 0x1A7 accumulates the divisor and chains to the old INT 08h. **So the DOS clock is calibrated to the display's vertical retrace and re-synchronised. It is not a fixed PIT rate.** |
| Strings: mgraphic.exe, fonts.cv, .pic, .pal, .txt; the four graphics menu entries; "MCGA is not supported…" in MGRAPHIC | Confirmed. **New:** the same menu also asks for **sound**: "No sounds please", "IBM sounds", "Tandy sounds", "AdLib/Sound Blaster". "Allocated 1Mb of space" / "MS-DOS lied to us" are `$`-terminated strings next to game strings (CIV_UNP 207,790). That does not support a link to the graphics-driver loader. |
| PIC chunks: 2-byte tag + 16-bit little-endian length | Confirmed. **Clarify:** the length counts only the data after the 4-byte chunk header (next chunk at p+4+len). Examples: SPRITES `X1` length 9,382 = file size − 4. E0 is always 258 (data starts `00 FF`); M0 is always 770 (first 0, last 255, values ≤ 63); X0/X1 is w, h, then byte 11 in every file. |
| Sizes: most 320x200; CBACKS1..3 320x65; CBRUSH 182x95 / 136x95; SLAG2/SLAM2 197x67; TORCH 13x14 | Confirmed (94 files are 320x200; CBRUSH0/2/4 are 182x95, CBRUSH1/3/5 136x95) |
| No E0: SPRITES, SP257, TER257, KING03, KINK00, KINK03, MAP, SLAG2, SLAM2, TORCH. X1: KINK00, KINK03, MAP, TORCH (+ SPRITES) | Confirmed |
| PAL: 782 bytes, M0, then an empty X0 (length 4, zero data) | Confirmed for all 38 |
| FONTS.CV: word 9, then 0x007C, 0x03E4, … | Confirmed (…0x068C, 0x0F2F, 0x1BAC, 0x2890, 0x3438, 0x3B60, 0x4347) |
| All 13 TXT end in ^Z and use CR LF | Confirmed |
| Binary prefixes: first `*` at 530 in most files, 23 in BLURB4; early ^Z (KING 425, BLURB2 453) | **Corrected.** 530 holds for BLURB0/1/2, ERROR, HELP, KING and PRODUCE. **BLURB3 is at 532**, and its prefix is all `0` (0x30) with no bytes ≥ 0x80. BLURB4's "`*` at 23" is an 0x2A byte *inside* the binary prefix (after 0xDE), so it is probably not a text marker (inferred). KING 425 and BLURB2 453 are confirmed. |
| INTRO.TXT uses CP437 box characters and says "Version 475.01"; CREDITS contains "L%" | Confirmed. "L%" stands where a name's middle initial goes, which supports the full-stop inference. |
| capstone `__version__` 5.0.7, pip 5.0.9 | Confirmed (`importlib.metadata`) |
| DOSBox Pure 2026.10.08; `--aspect-ratio off`, `--scanlines`, `--crt-filter`; saves in `%LOCALAPPDATA%\DOSBoxPureStandalone\<id>\` | Confirmed (BUILD-INFO.txt, MAKEGAME-GUIDE.md). The guide also documents a fallback to a folder beside the packaged exe if LocalAppData cannot be written. |
| `build/dosdata` | 176 files, all SHA-256 equal to `dos/`, read-only. Matches STATUS X0. |

---

## B. Conflicts

### B1. With the base rules and the current repository

1. **F98 against 5.7 / S-1.** F98 (the user's resizable-window request) already has:
   - a resizable window with a 320x240 minimum client (src host_win32.c:1237);
   - `fit` with **HALFTONE** smoothing at non-integer sizes, and COLORONCOLOR at whole k;
   - a cursor rebuilt by `CreateIconFromResourceEx` at `32*dw/640`.

   5.7 instead requires a 640x480 minimum, `integer` as the default (black borders, never larger than k·640), `fit` limited to `nearest`/`sharp` (no HALFTONE, which GDI-defined output cannot pass a golden test), and a nearest-neighbour cursor scaled by an integer factor. RUNNING.md currently promises "smoothed at other sizes". After the extension, a maximized window on the user's 2560x1600 monitors shows 1920x1440 with borders instead of today's fitted 2133x1600. That is a visible change to something the user asked for an hour earlier: record it as superseding F98 and tell the user.
2. **Base Win32-headless checks change by design, so G-1's "every base test passes" cannot hold as worded.** `test_host_win32.c`:
   - expects a press at (2000,3) to be **delivered clamped** to (639,1); 5.7 says a press outside the image is not delivered;
   - expects `--scale 4` to be refused; 5.11 adds `--scale <k>`;
   - checks the 640x480 `hw_pixels` DIB, which the present path replaces.

   G-1 must apply to core, rt, w16 and the harness, and list the Win32-headless checks the extension supersedes.
3. **G-1's "every base frame hash unchanged" has no golden to compare against.** `scenarios.py` only checks that rows are *reached*. `gate3b.py` compares checkpoint snapshots, not frame hashes or the event trace. X0 or S1 must freeze a baseline: the features.py first-stable hashes per row, the events.log of every p4 scenario, and the start-up run.
4. **`host_present` and S1.** Feasible without changing base hashes. The headless hash is SHA-256(screen640x480 + 768-byte palette) at every `host_present`; the rectangle is ignored (src host_headless.c:293). Keep `host_present` and its call points, and add a separate composed-frame call. One point needs definition: the "two hashes" relation (5.1) holds only if the Windows-profile presented frame is built from the screen *as of the last `w16_present`*, not from the live screen, because `w16_present` is throttled and the virtual screen can hold output that was never presented.
5. **O7 feasibility.** Feasible.
   - The tick belongs exactly where `w16_present(0)` is called: PeekMessage (queue.c:442, after `w16_host_sync`), GetTickCount (clock.c:193), SetCursor (user_cursor.c:149) and the DOS time service (dos.c:358).
   - The throttle is **virtual** time (16,667 µs of `w16_clock_us`), and forced presents bypass it (palette changes). The prompt should say which clock throttles the tick: virtual in headless (needed for 7.4 determinism), host refresh in Win32. This machine is 2560x1600 at 59 Hz.
   - Win32 `host_present` pumps host messages. A tick that presents pumps too; that only fills the input ring, so it is acceptable.
6. **`fr_enter` in all variants.** Yes. `fr_enter(const FrameDesc *fd, …)` carries `fd->addr` in every build; only the coverage record is Checked-only (vm.c:701). All 699 ported functions call it, and callers push their arguments on the emulated stack in every build (`stk_push16` before each call), so entry probes can read `[bp+6…]`. Statement-level probes are **not** possible in Release (`VM_SITE` is an inline store there), so O2 must stay at function entry and exit.
7. **`CIV_OBSERVER=0` is necessary but not sufficient for G-1.**
   - It proves nothing about w16 changes that are not behind the switch: the tick, the input-filter hook in `host_sync.c`, the probe hook in `fr_enter`. Define `CIV_OBSERVER=0` to remove all of them.
   - Also compare against the frozen pre-extension goldens (item 3) in Checked and Asan.
   - It needs its own build directory: `build.cmd` has only Release/Checked/Asan and would overwrite Checked.
   - The O3 read API must not use the checked `mem_rd*` accessors, which record out-of-range accesses.
8. **Harness functions.** `w16_queue_post_key` and `w16_queue_post_input` are real (harness.c:870-872). But harness scripts post to explicit windows (`hwnd <hex>`, client coordinates, `hwnd active`), and `w16_host_sync` returns immediately under `W16_TIMING_NONE`. So the 7.8 mode needs a new w16 timing mode (host input on, clock virtual) and new HostEvent-form scripts with screen coordinates; existing scripts cannot be reused.
9. **5.1 understates the w16 changes.** "platform/w16 gains only observer calls, query functions, the tick and host.h additions" leaves out three things the prompt itself requires: the I2 filter hook inside `host_sync.c` (the filter must run at the poll for I4's state-gated release), the 7.8 timing mode, and the probe dispatch in `vm.c` `fr_enter`.
10. **Progress reports.** Extension 11 says "Keep the user's half-hourly progress reports". The user stopped them on 2026-10-10 at 16:22 (STATUS user directions; memory). The user wins, and STATUS already records this.
11. **"No DOS bytes" against base rule 6.13.** 5.9 requires "layouts … timings … read from the DOS image at recorded offsets, never copied into source". Base 6.13 keeps instruction immediates as C constants with an address comment. Most DOS layout coordinates and durations will be immediates. Reading each immediate at run time from a code offset is possible but brittle and doubles the evidence burden. A rule is needed: data-segment tables are read at run time; instruction immediates may stay as C constants with their `R:`/`O<n>:` address comment.
12. **Single-threaded host.** Host modal loops block the game thread: caption drag, resizing, the system menu. S-1 says "resizing never reaches the emulation". Under `--timing host` the emulated clock jumps after a long drag, and DOS timelines freeze during it. Record this, or move the host window to a UI thread (base 5.5 allows that).
13. **Stale comment.** `host_sync.c:18` says `--timing host (default)`; the default is classic (civ64_start.c:60). Trivial.

### B2. Internal consistency of the extension

- **T5/T4/I4 against I1:** consistent. Forwarded skips and queued translations come from user actions.
- **T5/I6 against D-2/7.4:** core input depends on the visible profile by design (a key is consumed during the DOS intro and reaches the title menu in Windows). 7.3 and 7.4 must inject *core* input after the filter (they do), and 7.4 must say so explicitly.
- **O4 (no `g_randSeed`)** against "follow the core's decisions": consistent if the decisions are observed through draw and probe events.
- **5.9 "`--dos-data` … no default" and 5.11 "the DOS profile needs `--dos-data`"** are superseded by phase R (B3).
- **2.1 "DOS inputs: every run uses `build/dosdata` or a fresh copy under `build/run`"** does not cover R's `CivDos` folder or ZIP under `build/x64/<variant>/` (both derived copies). Extend it.
- **5.8 mirror equality "at every present"** is impossible as written (C, phase M).
- **5.4 W-over-N** and **5.3 A/N frames:** consistent.
- **2.1 DOS oracle item 5:** the program also asks for a sound device. Under "stop and ask if you cannot answer from the files", the agent would stop at every run. Pre-decide the answer (for example "No sounds please", recording the effect on timing).

### B3. Phase R (the user's resource-lookup requirements) against both prompts

**What R supersedes** (record in DESIGN/STATUS as "user direction 2026-10-10"):
- **Extension 5.9 / 5.11** "`--dos-data` … no default" and "DOS profile needs `--dos-data`": replaced by DOS lookup in this order: `--dos-data`, ZIP, `CivDos`, remembered location, optional ask.
- **Base 4 item 2 / RUNNING** "`--data` default: the executable's folder": R's list has no "executable folder itself" step. Decide whether the old default is dropped, which a literal reading implies.
- **Base 2.3 host isolation** ("nothing writes … files outside the run's data directory"; "options come only from the command line") and RUNNING ("reads no … INI file"): R needs persistent remembered locations and a per-user extraction. This is covered only because the Settings-file bullet was kept. Its item list must grow by: Windows location (folder or ZIP), DOS location, a "DOS declined" flag, the fingerprint of the extracted ZIP, and the path of the extraction state. Extension 2.0 item 8 must add the extraction folder.

**What is kept:**
- **5.9 "the DOS directory must not be the data directory or lie inside it".** `--data <exe folder>` plus an exe-folder `CivDos` subfolder would put DOS inside the data directory. Keep the rule (the core lists the data directory), refuse that combination with a message, and refuse a browsed DOS folder inside the Windows data directory.
- **Refusing `original\CIVWIN`.** Apply the existing final-path check (civ64_start.c:122-154) to every R source: the `CivWin` subfolder (it may be a junction), remembered locations, and browsed choices. Refuse without remembering; when browsing, re-ask instead of exiting with code 2. A ZIP made from `original\CIVWIN` is fine (it is a copy). The pinned `civ.exe` check applies after extraction.
- **"No DOS bytes" / "no original bytes":** unaffected. Test ZIPs are built at test time under `build/`.

**Must be designed (R):**
- **Locations.** ZIPs in the executable folder (the user did not say where; the agent decides and records). Enumerate the folder and compare ASCII case-insensitively, which also works in case-sensitive directories. Priority order CivWin > Civ-Win > Civ_Win, with a defined tie-break between case variants. A match that is a file where a directory is expected (or the reverse) is skipped.
- **What "found" means.** Decide whether an existing but invalid candidate (bad ZIP, wrong `civ.exe`) stops with an exit-2 message or falls through with a warning. Stopping is recommended so problems are not hidden.
- **ZIP reading with no third-party library.** Windows has no raw-DEFLATE API (Compression API "MSZIP" is framed). Shell or `tar.exe` extraction would run another program and show UI. So write:
  - an own portable inflate (RFC 1951: stored, fixed and dynamic Huffman; reject over-subscribed trees, codes 286/287 and 30/31, distances beyond the output; output exactly equal to the declared size; CRC-32);
  - a central-directory parser: last-64 KiB EOCD scan, comment length, entries matched to local headers, data-descriptor flag.

  Recommended home: a portable module under the base section-1 rules using `host_alloc`, so the same code runs headless and under ASan.
- **ZIP safety:**
  - methods 0 and 8 only (Deflate64 = 9, bzip2, LZMA, AES and similar get a clear message naming the method);
  - refuse encrypted entries (flag bits 0/6) and multi-disk archives;
  - ZIP64: parse the extra-field sizes or refuse, but decide;
  - names: no `..`, absolute paths, drive letters, `:` (ADS), control characters, device names (reuse `hw_valid_relpath`), trailing dot or space;
  - refuse duplicates after case folding, symlink entries (Unix mode in the external attributes) and overlapping local entries;
  - caps on per-entry size, total size and entry count.
- **Which files to extract.** Root entries, or the folder that holds `civ.exe`. 8.3 handling. Ignore non-game subfolders.
- **Atomicity.**
  - First extraction: inflate and verify everything (CRCs and the pinned `civ.exe`) into `…\civ64\CivWin.tmp-<pid>`, then rename the directory (same volume).
  - Refresh: replace a game file only if it is unchanged since the last extraction (manifest hash); otherwise keep it. This covers `civ.prf` and a user-overwritten `CAE3540B.SAV`, both of which the ZIP also contains. Delete files dropped from the ZIP only if unchanged. Write the manifest last, with an "in progress" marker so the next start redoes the refresh.
  - A named mutex or lock file against two concurrent civ64 instances; files a running instance holds open are skipped with a message.
  - Keep the **manifest and state outside the data directory**. `host_dir_list` falls back to 8.3 alternate names, so a long-named manifest inside `CivWin\` could appear in the game's own file listings.
- **Remembered locations** go in `civ64.cfg`: UTF-8, written atomically.
  - A Windows location that is missing or invalid: run steps 1–4 again, then ask with a message naming the old path. Keep the old entry until a new valid choice. Cancel ends with exit 2.
  - DOS is "optional without asking at every start": ask once on first start with Skip / "Don't ask again" (stored as "declined"). Later starts never ask; the profile-switch chord message and the system menu offer "Locate DOS files…". A remembered DOS location that has gone missing makes the DOS profile unavailable for that run, without a dialog.
  - Read DOS ZIPs **in memory** (no extraction), so `dos` stays read-only. Generalise the 5.1 "DOS directory" host service to "DOS source (directory or ZIP)".
- **Host side effects of "browse".** The shell file/folder dialog (IFileDialog) persists most-recently-used lists and size state under `HKCU\…\ComDlg32` and may touch shell caches. That breaks base 2.3 "nothing writes the registry". The base track avoided the system dialog for exactly this reason (an in-memory dialog is used, src host_win32.c:9). **User decision needed:** accept the system picker (record its side effects) or build an in-app folder or ZIP chooser.
- **A writable data directory.** An exe-folder `CivWin` under Program Files is read-only, so saves would fail through the game's own error path. Detect it and show a message, or treat it like the ZIP case. Decide.
- **The per-user extraction folder is shared by every civ64 copy and every ZIP.** Record this. Fingerprint by ZIP identity so two different ZIPs do not refresh-flip each other.
- **R test implications:**
  - Win32-headless tests must never show a dialog: every prompt goes through a hook that returns cancel or a scripted choice in quiet mode;
  - the executable folder and the LocalAppData root must be injected (the w32 tests' own exe folder is `build/x64/<variant>`), and tests must never touch the real `%LOCALAPPDATA%`;
  - the ZIP reader gets unit and fuzz-style vectors under ASan: truncated archive, bad EOCD comment, CRC mismatch, traversal names, duplicates, oversized declared sizes, encrypted entry, ZIP64, Deflate64 refusal, overlapping entries;
  - a fault-injection seam for crash-in-the-middle refresh;
  - one end-to-end test with a ZIP built from `build/gamedata` under `build/`;
  - the base test expectations for the default data directory change.
- **Agent runs.** Bring-up and UI checks must keep passing `--data`/`--dos-data`, or use the injected root. A real-path extraction triggered by the agent writes `%LOCALAPPDATA%\civ64\CivWin` outside the Files grant.

---

## C. Feasibility and risk per phase

- **X0.** The review is done. Facts mostly hold (corrections in D). The ledger was updated concurrently and is consistent.
- **S1.** Low risk.
  - Keep `host_present` for the core hash and add the composed-frame path.
  - Freeze the frame-hash and event-trace goldens first (B1.3), otherwise G-1 cannot be shown.
  - 7.1 goldens run in Release too (unit test).
- **S2.** Medium risk.
  - F98 supersession (B1.1). Base Win32-headless checks to supersede (B1.2).
  - Modal-loop stalls (B1.12).
  - The **8 ms full 3840x2160 "scale + copy" target cannot be measured on screen here**: the monitors are 2× 2560x1600 at 59 Hz and there is no 4K display. Define the measurement as a portable scale into a host-size buffer plus `SetDIBitsToDevice` into a memory-DC DIB of 3840x2160 (or a 2560x1600 on-screen measurement, extrapolated), per policy. GDI copies of a 33 MB XRGB frame may exceed 8 ms. Make it a recorded target with the damage-only path as mitigation, not a hard blocker.
  - `sharp` must be implemented analytically (coverage weights), not as a ceil-upscale followed by averaging, to stay fast at 4K.
  - 4:3 pairs at 5 % tolerance: (4,5) on 1080p; (7,8) at 4.8 % on 2560x1600.
- **R.** Medium risk: B3. Without the picker decision, the "ask and browse" step cannot be finished in line with host isolation.
- **D0.** High effort, and the 12 % weight is light.
  - Everything from scratch: an overlay manager (INT 3Fh to be confirmed) and 23 overlays, a driver interface, and a **retrace-calibrated clock** (A2), so DOS durations become "ticks at a measured rate" rather than fixed PIT ticks. 6.4's "PIT ticks (1,193,182 Hz / divisor)" must allow a measured divisor. Under DOSBox the rate follows its emulated refresh.
  - The EXEPACK part is de-risked (A2).
- **D1.** Shadow surfaces for every port, observer completeness, the composition snapshot rule (B1.4) and the tick clock (B1.5).
- **D2.** Moderate. PIC LZW (11-bit) plus whatever RLE the listing shows, FONTS.CV, texts with binary index prefixes (BLURB3/4 differ), and the pointer.
- **D3.** Medium-high risk. Probe cost per `fr_enter` (use a hash, or a probe bit by address). O3 raw readers. The 7.8 timing mode. The `CIV_OBSERVER=0` variant directory. The full 7.3 matrix (23 scenarios + S1..S5 including the soaks, times about 5 variations) is very long; run a subset at gates and the full matrix at X9.
- **M.** **Gate impossible as written.** Mirror equality "at every present of every scenario" cannot hold:
  - between an exposure and the core's WM_PAINT the map client shows the class brush or saved bits;
  - mode-1 dissolves blit square by square;
  - scrolling uses screen-to-screen BlitDCRect with pixel scroll offsets;
  - blinking, move and combat animations, founding and nuke effects, and text are drawn into the map window by routines outside the listed renderer set.

  Fix: define equality at stable frames after each completed core map redraw or flush (`RedrawMapWindow`, `RedrawMapSquare`/`FlushSquareToWindow` and `CopyPortToWindow` of `g_mapOffscreenPort`), with a recorded list of transient overlays. Or define the in-view map layer as a scaled replay of the core's map-port draw events, which makes equality at m = default hold by construction; draw from state only outside the view.
- **D4.** High risk. DOS timing model (retrace-calibrated clock). The Windows title menu runs *inside* the intro movie callback (frame 1260), so the "core is still in its intro" state must be defined for T4/T5. Birth runs inside CPU-bound world generation (ticks happen only at TickCount queries). The oracle needs the sound-device choice.
- **D5.** Medium: adapters for MenuZ dialog 144 and the I5 inverse mapping per scene.
- **D6.** High: the A canvas, the DOS map rules, R menus, and zoom in the DOS profile.
- **D7.** Very high, the largest unknown. It is mitigated by the fact that Windows full-screen scenes draw through the DOS-lineage logical layer (logical replay).
- **D8 / X9.** Records. Also: G-1 against frozen goldens; hash checks of `original/` and `dos/` (attributes and LastWriteTimeUtc).
- **"No DOS bytes".** Achievable for tables, pictures, palettes, fonts, text and code (all read at run time; EXEPACK is an algorithm). It is not reasonably achievable for layout and timing immediates without the B1.11 rule.

---

## D. Corrections and decisions

1. **BLOCKER (user).** The R "browse" step: the system file/folder picker writes `HKCU\…\ComDlg32` most-recently-used state, which conflicts with base 2.3 "nothing writes the registry". Allow the system dialog with its side effects recorded, or require an in-app chooser.
2. **BLOCKER (agent decides, then reports).** Mirror equality (5.8, 7.5, Z-2) is impossible "at every present". Redefine it per C/M (stable frames after core map flushes plus a list of transient overlays, or the event-replay layer) and record the definition in DESIGN.
3. **BLOCKER (agent decides, then reports).** G-1 "every base test passes" conflicts with the extension's intended Win32-headless changes: delivered clamped press, `--scale 4` refused, the `hw_pixels` 640x480 DIB, the 320x240 minimum. Restrict G-1 to core, rt, w16, the harness and the unit tests, and list each superseded w32 check with the rule that replaces it.
4. **MAJOR (agent).** Freeze the base goldens at X0/S1: features.py first-stable hashes per row, p4 events.log hashes, the start-up run, `gate3b-golden.txt`. `scenarios.py` does not compare frame hashes today, so G-1 cannot be verified without this.
5. **MAJOR (agent).** Define `CIV_OBSERVER=0` to remove events, probes, the presentation tick, the input-filter hook and the 7.8 mode. Give it its own build variant and output directory. Its comparison supplements the frozen goldens; it does not replace them.
6. **MAJOR (user, a one-line question).** "No DOS bytes" against base 6.13: allow DOS instruction immediates (coordinates, sizes, durations) as C constants with `R:`/`O<n>:` comments; read only data-segment tables at run time.
7. **MAJOR (agent, then report to user).** S-1/5.7 supersede F98 (HALFTONE fit, 320x240 minimum, `CreateIconFromResourceEx` cursor scaling). Update F98, RUNNING and DESIGN 5. Tell the user that the default `integer` changes what they see.
8. **MAJOR (agent, then report).** Phase R supersedes 5.9/5.11 "`--dos-data` … no default" and base 4 item 2 "default: executable folder". Extend the Settings-file bullet and extension 2.0 item 8 (remembered locations, declined flag, ZIP fingerprint, extraction folder). Keep 5.9 "DOS not inside the data directory" and the `original\CIVWIN` refusal for every R source. Confirm with the user that the old exe-folder default is dropped.
9. **MAJOR (agent).** The R ZIP design: own portable inflate and parser; methods 0 and 8; refusal rules; ZIP64 decision; caps; name sanitising; CRC; in-memory verification before any write; temp folder plus rename; refresh only of unchanged files (manifest kept **outside** the data directory); lock against concurrent instances; DOS ZIP read in memory.
10. **MAJOR (agent).** R test seams: inject the exe folder and the LocalAppData root; a quiet-mode prompt hook (no dialogs ever); never touch the real `%LOCALAPPDATA%` in tests. Agent bring-up runs always pass `--data`/`--dos-data`; a real-path extraction run needs the user's OK.
11. **MAJOR (agent).** The DOS clock is retrace-calibrated (0x215/0x258/0x276 with port 0x3DA). Change 6.4 and 7.7 to "durations in DOS ticks with a measured divisor; real-time period inferred (VGA refresh) or DOS-oracle-observed".
12. **MAJOR (agent).** The 8 ms 4K gate: specify the measurement (offscreen 3840x2160, per policy; no 4K monitor here). Make it a recorded target with damage-only mitigation, not a hard S2 blocker.
13. **MAJOR (agent).** O7: throttle the tick by virtual time in headless and by host refresh (59 Hz here) in Win32. Build the Windows-profile presented frame (and W elements) from the snapshot of the last `w16_present`, so the "two hashes" relation holds.
14. **MINOR (agent).** 5.1: add the I2 filter hook in `host_sync.c`, the 7.8 timing mode (host input with virtual clock) and the `fr_enter` probe dispatch to the list of allowed w16 changes.
15. **MINOR (agent).** 7.8: existing scripts (`hwnd` targets, client coordinates) cannot be fed as HostEvents. Write new screen-coordinate scripts for both forms.
16. **MINOR (agent).** I5: PollMouseClick's stores are at 1108:017A/018F (signed 16-bit `imul`/`idiv`, dialog clicks only); 1038:0CB6/0CCE belong to WaitForKeyOrClick (unsigned `>>4`).
17. **MINOR (agent).** Drop the Q86 citation for WaitForKeyOrClick (Q86 is GetScreenTextWidth text centring).
18. **MINOR (agent).** Section 3 logical layer: the status window case is 0 <= x < 200 (negative x is not drawable). In dialog + city-tile mode, drawing goes to the dialog port.
19. **MINOR (agent).** 5.8: the core's view has pixel scroll offsets `g_mapScrollX/Y` (1408:00C6/00C4) and scrolls by screen-to-screen blit; handle both in the renderer and in the inverse mapping.
20. **MINOR (agent).** Section 3 PIC: the chunk length excludes the 4-byte chunk header; E0 data starts `00 FF`.
21. **MINOR (agent).** Section 3 TXT: BLURB3's first `*` is at 532 and its prefix has no bytes ≥ 0x80; BLURB4's `*` at 23 is probably an index byte.
22. **MINOR (agent).** "Allocated 1Mb" / "MS-DOS lied to us" sit among the game's `$`-strings; drop the guess that they belong to the driver loader, or label it weak.
23. **MINOR (user, or agent records a default).** DOS oracle 2.1 item 5: the program also asks for the sound device. Pre-decide the answer and record its timing effect, otherwise the "stop and ask" rule triggers at every run.
24. **MINOR (agent).** Extension 11 progress reports: the user stopped them. Already recorded in STATUS; amend the prompt text.
25. **MINOR (agent).** 2.1 "DOS inputs: every run uses `build/dosdata`…": extend to ZIP or `CivDos` copies made from it under `build/`.
26. **MINOR (agent).** `--scale` is refused above 3 today (civ64_start.c:79) while `auto` goes to 8. Unify with 5.11 `--scale auto|<k>`, with k ≤ 8 recorded.
27. **MINOR (agent).** Record that host modal loops (drag, size, system menu) block the game thread. Under `--timing host`, resizing then reaches the emulated clock, so qualify S-1, or move the host window to a UI thread.
28. **MINOR (agent).** 7.4 must state that the compared runs inject identical *core* input (after the filter), because consumption (I6/T5) depends on the visible profile.
29. **MINOR (agent).** Shorten the 7.3 matrix at intermediate gates (scenarios plus S1..S3); run the soaks S4/S5 under every variation only at X9.
30. **MINOR (agent).** R: an exe-folder `CivWin` may not be writable (Program Files). Detect and report, or copy to LocalAppData. Decide and record.
31. **MINOR (agent).** R: the ZIP location is unspecified. Use the executable folder, with ASCII case-insensitive enumeration and a deterministic tie-break between case variants.
32. **MINOR (agent).** R: an invalid but present candidate stops with exit 2 and names it, rather than silently falling through. Refused or invalid browsed choices are never remembered.
33. **MINOR (agent).** R: use `SHGetKnownFolderPath(FOLDERID_LocalAppData)` rather than the environment variable, consistent with "reads no environment variable".
34. **MINOR (agent).** Fix the stale `host_sync.c` header comment ("--timing host (default)").

All Windows addresses I re-checked exist and match their descriptions. The DOS file facts are confirmed apart from the corrections above.

Key scratch scripts (read-only checks, not in the repository) are in `<scratch folder>`:
- dosfacts.py
- exepack.py
- pit.py
- pit2.py
- picfacts.py
- fn.py

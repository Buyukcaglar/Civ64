# D4a DOS-fidelity review (independent, read-only)

Reviewer: independent read-only review of unit D4a's DOS transcription (2026-10-12).
Sources compared: `present/dos/*.c` against `build/dos/disasm/mgraphic.lst` (driver, `G:0000:xxxx`) and
`build/dos/disasm/root.lst` (`R:ssss:oooo`), `docs/dos/DRIVER.md`, `FORMATS.md` 2, and the design
`docs/verify/ext-d1-draft-B.md` 3, 4, 5, 9.3, 10. The raster-op table bytes at G:0000:0208 were read
from `build/dosdata/MGRAPHIC.EXE` (read-only Python): `88 20 08 30` (store, AND, OR, XOR).
No build, test run, git or DOS program execution. Status: see the last section.

## Summary

* BLOCKER: 0. MAJOR: 0. MINOR: 6 (listed below).
* The driver transcription in `pdos_draw.c` is faithful instruction by instruction for every
  function I traced (G#2/3/5/6/10/14/19/20/31/32/39/41/42, R:0000:0BFA, R:0000:0E3C/100A/104F).
  The G#21 text engine in `pdos_glyph.c` (set-up, right/left/vertical clip, opaque/transparent glyph
  loops, colour bytes, write-back, return value) and the R:0182 helpers match the listing,
  including the 8-bit counter wrap (count 0 = 256) and the early-exit return value `x - ox`.
* `pdos_pal.c` (6-to-8 table, G#28 placement, fade arithmetic of R:0000:05B7, cycling of
  R:0000:0382/03FA/044A) and `pdos_rand.c` (srand/rand/random(n)) match the listing.
* No unit-test mirroring of a misreading was found in the functions above, because no misreading
  of pixel behaviour was found. The findings are edge cases that the model deliberately or silently
  does not reproduce, and one record wording error.

## Findings

### F1 (MINOR) G#19 WriteRow with count = FFFFh
* `present/dos/pdos_draw.c:323`. Listing G:0000:03F4..0404: `mov cx, [bp+0Eh]; inc cx; shr cx, 1;
  rep movsw` in 16 bits, so count = FFFFh gives cx = 0 and writes nothing.
* C: `n = 2u * (((uint32_t)count + 1u) >> 1)` in 32 bits gives 65536 bytes (capped only by the
  per-write drop).
* Input: `pdos_write_row(s, 0, 0, src, 0xFFFF)`: DOS writes 0 bytes, C writes the whole page and reads
  64 KiB from `src` (an over-read of the caller's buffer as well).
* Reachability: none known (the three callers R:1FA1:01A2/04D2/0536 pass row widths). Fix:
  `uint16_t cnt = (uint16_t)(count + 1u) >> 1; n = 2u * cnt;`.

### F2 (MINOR) G#2 GrabSprite ignores the sprite arena capacity
* `present/dos/pdos_draw.c:169..190`. Listing G:0000:0A78 (BeginSprite) returns 0 and G#2 then
  builds nothing when the arena (G#18) is closed or full (G:0000:0A84 `jbe`); G:0000:0AF9..0B14
  (AddSpriteRow) decrements the stored height (`dec word es:[2]`) and closes the arena when the next
  row does not fit, so a grab larger than the free arena keeps only the rows that fit.
* C allocates `w * h` bytes on the host and always grabs every row.
* Input: a grab whose `rows * (w + 4)` exceeds the arena opened by the scene (G#18); DOS keeps a
  shorter (or no) sprite, C a full one. Reachability depends on D4b/D5 renderers' arena sizes; the
  design (4.2) gives `PdosShapeBuf` as B's own save-under, so this is a modelling choice, but it is
  not stated anywhere. Fix: document it in `pdos_draw.h` (or carry an arena budget if a renderer is
  found that grabs more than its arena).

### F3 (MINOR) Span-skip column G:0000:1986 is per surface instead of global
* `present/dos/pdos_draw.c:481, 769, 785`; `pdos_mach.c:20, 39`. Listing: G:0000:1986 is one driver
  variable written only by G#49 SetPortReg (G:0000:046D, from R:0000:100A line and R:0000:104F
  pixel), read by G#39 at G:0000:0436 for every fill on any page.
* C keeps `span_x` per `PdosSurf`. The rule `right == left && (left == 0 || left == span_x)` matches
  G:0000:042E..043B exactly; only the scope of the variable differs.
* Input: draw a line through a port of page 0 whose largest x is 199 (sets 1986h = 199), then a
  1-pixel-wide FillRect on page 1 at absolute x = 199: DOS skips the column, C draws it (page 1's
  `span_x` is still 319). Also the initial value differs: 0FFFFh for non-page surfaces versus the
  file's 013Fh.
* Severity MINOR (1-pixel-wide fills right after a line/pixel on another port). Fix: hold the value
  in `PdosMach` (one per machine) or note it as a Choice in draft B 4.2, which currently says
  "per surface" without the DOS-global caveat. (The DOS pages start at 013Fh as in the file; the
  0FFFFh start of non-page surfaces has no DOS counterpart.)

### F4 (MINOR, record wording) "CopyRect overlap-safe, SRCCOPY through a temporary buffer"
* `docs/ext-D4a-record.md` (module table, `pdos_draw` row) claims the copy is overlap-safe through a
  temporary buffer. The code (`pdos_draw.c:339..375`) correctly transcribes G#20 G:0000:0835..0844
  (`rep movsw` then `rep movsb`, forward, word read before word write, no temporary buffer). Code
  matches the listing; the record sentence is wrong and should say "no overlap handling, forward,
  word granularity" as draft B 4.2 does.

### F5 (MINOR, accepted design) G#31 ShowPage leaves the pointer image in the source page
* `pdos_draw.c:377..384`. Listing G:0000:0649..064D: ShowPage first calls G#9 (G:0000:030E), which
  saves the page's pixels under the pointer and draws the pointer with G#6 **into page n**; the copy
  to the screen follows. G#15 restores the save-under only into page 0 (G:0000:0251), so page n keeps
  the pointer pixels until redrawn; a later CopyRect from page n can carry a "ghost" pointer.
* Draft B 4.2 / 6.7 deliberately do not model the software pointer (host cursor), so this is an
  accepted deviation; I record it only because the record does not mention the ghost effect.
  It matters only while the pointer is shown during page flips (DGROUP:5876 set, 5403 clear).

### F6 (MINOR) G#28 LoadPaletteBlock with last < first
* `pdos_pal.c:44`. Listing G:0000:017C..0188: `cx = last - first + 1` in 16 bits, then G:0000:01A1
  writes cx triples with the index wrapping at 8 bits. last < first gives a count near 65536
  (wrapping writes over the whole DAC, reading far past the chunk). C writes nothing.
* Not reachable with the shipped files (PALETTE 5: every M0 chunk is 0..255). No fix needed beyond a
  comment.

## Confirmed matching the listing

Each item below was traced instruction by instruction; "matches" includes clipping, signedness,
loop bounds, transparency and write order.

* **G#3 RecolourRect** G:0000:009A: parameter order (port, x, y, w, h, old, new), origin added in 16
  bits, `cmp ah,[di]` then `stosb`/`inc di`, row step 320 - w, `loop` and `dec bp` count 0 = 65536.
* **G#6 DrawSpriteClipped** G:0000:0C3E + clip G:0000:0C77 + draw G:0000:0D68: unsigned `-y >= h`
  and `-x >= w` rejects, `maxy/maxx < 0` and `y > maxy`/`x > maxx` (signed) rejects, excess bottom/
  right only when positive, returned rectangle (x + skip, y + skip, w - skips, h - skips), zero
  rectangle on rejection. The dense-array form draws exactly the pixels of the run form: each run
  row is [first nonzero .. last nonzero] (G#34 G:0000:0B2E..0B72) and zero bytes inside a run are
  skipped at G:0000:0DE1.
* **G#32 DrawSprite** G:0000:0D47: G:0000:0D12 zeroes the clip, so no clip; origin added; 16-bit
  offset wrap.
* **G#2 GrabSprite** G:0000:0B85: absolute page coordinates, `abs(page)`, row step 320 (apart from F2).
* **G#5 ClearPage**, **G#14 GetPixel** (absolute, no port), **G#20 CopyRect** (origins of both
  ports, `w == 0` / `h == 0` return, forward word-then-byte copy), **G#31 ShowPage** (page 0 is a
  no-op; 64000 bytes) apart from F5.
* **G#10 DissolveToScreen** G:0000:06B7: LFSR `shr si,1; jnc; xor si,B400h; while si > FA00h`, start 1,
  offset `si - 1` with `movsb` restoring si, 64000 iterations, page 0 returns, `jcxz` duration 0,
  8800 / duration with a zero quotient raised to 1 (G:0000:06FD). The per-frame split is the
  design's (draft B 4.2); the calibrated delay itself is not modelled (timing, not pixels).
* **G#39 FillSpansReg** G:0000:040A + **R:0000:0BFA FillRect**: `w <= 0`/`h <= 0` return, first row
  `y + oy`, any first row < 0 cancels the whole fill (`js`), `first > last` cancels, left/right in 16
  bits, `right < left` (unsigned) skips the row, the 1-pixel skip at left 0 or left == 1986h, plain
  stores (G#39 ignores the raster op). Rows past 199 are dropped (the span arrays and the row table
  hold 200 entries; DOS would read the page-segment table as row offsets, which is run-time data):
  acceptable under 4.1.
* **G#41 SetColourReg** G:0000:020C: raster op = high byte & 3 through the table 88/20/08/30
  (`PDOS_OP_STORE, AND, OR, XOR`), confirmed against the file bytes.
* **G#42 LineReg** G:0000:0599: origin added to both ends, swap when y1 > y2 **unsigned**, single pixel
  only when both coordinates equal, |dx| with `neg` on sign, x-major when |dx| >= dy (unsigned),
  straight runs for diagonal/axis lines with `(major | minor) + 1` pixels, Bresenham error start
  `-((major + 1) >> 1)` (16-bit `shr`), `js` test, major + 1 pixels, raster op on every pixel.
* **R:0000:0E3C line clip**: outcodes (R:0000:0FC8), inside-end swap at R:0000:0EF1 and its store into
  slot 1, trivial reject on a common bit, the overflow halving of DX/DY (`cmc; rcr` equals an
  arithmetic shift of the true 17-bit difference), half deltas by `sar`, x limit chosen by the sign
  of the outside end, y limit choice R:0000:0F5D..0F6D, the rounding sequence R:0000:0F46..0F59 and
  0F7E..0F91, the divide-error handler R:0000:0FE9 (+-7F00h by the sign of product-high xor
  divisor, remainder 0, 286 return-address semantics), the second-end pass with the original
  deltas, final slots. **R:0000:104F pixel**: inclusive 0..maxx/0..maxy reject, raster op.
* **G#21 DrawText** G:0000:11D7..13B0, 0FAC..10A6: font header offsets (-8 first, -7 last, -6 bytes
  per row, -5 fixed, -4 height, -3 spacing, -2 extra), width table at P - 8 - k, row stride
  `k << (bpr - 1)`, rows = `cbw(height + (style & 1 ? extra : 0))`; right clip (room + 1, cut
  written after the straddling character, `[620]` = overflow), left clip (start at the straddling
  character, `[61f]` = advance - overflow, x set to 0, early exit returns `0 - ox`), vertical clip
  (unsigned `jbe`, glyph pointer advanced by rows * stride, `ja` against maxy, bottom trim);
  per glyph: colour byte >= 80h sets `colour & 7Fh`, out-of-range codes skipped without advance,
  rtrim only when the next byte is 0, lskip on the first glyph only, word read big-endian (second
  byte from the next glyph's row in 1-byte fonts), opaque only when the style byte equals 1 with
  plain stores of colour/background, transparent with the patched raster op and `count - spacing`
  columns unless the next byte is 0, `dec ah`/`dec ch` counters wrapping at 0 (256), x advance by
  the full count, colour written back on normal end only, return value relative end x.
* **G#4 CharWidth** G:0000:115D (`pdos_fontset_advance`): 0 for codes >= 80h, font 0 or > count,
  codes outside first..last; `(width + spacing)` as a byte, `cbw`. **G#12** height + extra.
* **R:0182:002A/005C/0086/00B3/00EF**: colour stored into the port, style 0 then 1, shadow at y + 1 in
  colour 0, centring `(w + (w < 0)) >> 1` arithmetic, width as the sum of G#4.
* **6-to-8 table** `pdos_v8`: spot-checked v = 1, 10, 11, 31, 32, 52, 53, 63 against
  `(v * 255 + 31) / 63`.
* **G#28 LoadPaletteBlock** G:0000:0162: "M0" check, triples from block + 6 into first..last (apart
  from F6). **R:0000:04AA** target = 768 bytes from block + 6 as entries 0..255
  (`pdos_dac_from_m0`); **R:0000:04D4** target = one colour in all 256 entries (`pdos_dac_fill`).
* **Fade arithmetic** R:0000:05E1..0610: `s * not(w) + t * w` as 32 bits, `shl bp,1; adc bx,0`, low
  byte of the high word. The progression of `w` (R:0000:050C: steps = 6 * (n & FFh), batch from
  the VGA calibration, `w += 65536 / (batch * steps / 256 - 1)` per full pass, clamp FFFFh) is area
  C's per the design and was not reviewed here.
* **Cycling** R:0000:0382: unsigned `hi - lo` with `jbe` refusal, count min(hi - lo + 1, 16), capture
  from the DAC at lo, doubled copy minus the last entry, position 0; R:0000:03FA: direction from the
  sign of the slot argument (+3/-3 bytes); R:0000:044A: `pos - step`, `+ 3n` when negative, 0 when
  >= 3n, write 3n bytes from the doubled copy at pos. `pdos_cycle_step` matches for both directions.
* **pdos_rand**: srand R:2045:2AD8 (low word = seed, high word 0), rand R:2045:2AEA (`* 343FDh +
  269EC3h` through the 32-bit multiply R:2045:31DE, `(high word) & 7FFFh`), random(n) R:1DC4:005D
  (n and rand sign-extended, 32-bit product, `sar` 15 through R:2045:32C0, low word).

* **pdos_mach ports** (`init_ports`): checked against the bytes of `CIV_UNP.EXE` DGROUP:0098, 19C2,
  19D6, 19EA (read-only): page n, origin 0,0, largest 319,199, style 1 (screen) / 0 (pages 1..3),
  colour 0Fh, background 4, font 0; DGROUP:00AA = 0098h; DGROUP:2F98 = 0 (`box_texture` 0). The
  pointer words at port + 12h point at their own port, so DGROUP:[19E8] is the page-2 port 19D6
  that the texture and the border use (`m->port[2]`): correct.
* **pdos_ui**: outline R:1D05:0A05 (four lines, inclusive (x, y)..(x + w, y + h)), bevel R:1D05:0A66
  (top/right c2, bottom c1, left from y + 1 in c1), box R:1D05:096C (texture when colour 7 and
  DGROUP:2F98, else R:0182:0148 corner fill = FillRect(x + 1, y + 1, w, h); background stored into
  the port; bevel(x + 1, y + 1, w, h, 15, 8); outline(x, y, w + 2, h + 2, 0)), panel R:0238:1BB2
  (texture, bevel w - 1, h - 1, 15, 8), texture R:1DC4:03CE (fill 7 without VGA; 32 x 16 tiles from
  page 2 (288, 120) with the clamps of R:1DC4:007C, `jg` loop ends), border R:0866:260E (one
  `random(2)`, base C0h + 32r, the four corners, 23 side and 38 top/bottom tiles with the exact
  source offsets).
* **R:1F4D**: wrap preparation R:1F4D:0000 (the `^`, newline and column rules, the trailing string
  DGROUP:2FEE = "\n", verified in the file), wrapped drawing R:1F4D:0088 (break positions,
  `columns * 8 >= width`, style-0 drawing of each line, `^` skip, stop when y > C0h, last line),
  truncation R:1F4D:04F7 (for length >= 3), tokens R:1F4D:0471 (names at DGROUP:30AE verified in
  the file: `$US`, `$THEM`, `$BUCKS`, `$RPLC1`, `$RPLC2`; repeated leftmost replacement).
* **Play cycling slots** R:1DC4:05DD/0626: slots 1..3 over 60h..67h, 68h..6Fh, 70h..7Fh, period 0Fh,
  started with positive arguments (direction +1): `pdos_play_slots_setup` matches.
* **pdos_cursor**: torch = D4CE[7], GO arrow = D4CE[2], hot spot (0, 0) at R:01A8:0139 and
  R:0403:10AB (verified), index 0 transparent, colours from the presented DAC. The id-to-pointer
  table and the hidden rule follow draft B 6.7 (design, no DOS counterpart).
* **pdos_charmap**: every row of draft B 10.4 checked against the table (80h..FFh, 09h, 7Fh, BFh).

## Observations without severity (unreachable or design-level)

* **O1 DAC values are not masked to 6 bits on load.** `pdos_dac_load_m0`, `pdos_dac_from_m0` and
  `pdos_dac_load_raw` store the file bytes as they are; the DOS DAC keeps 6 bits, and the DOS
  cycling capture (R:0000:03CB..03D8) and fade start (R:0000:0554) read the DAC back, so they see
  masked values while the C reads `v[]`. Without effect while every palette value is <= 63
  (PALETTE.md: 6-bit RGB in every file). A `& 63` in the three loaders would make it exact for
  any input.
* **O2 Bytes outside the string.** `pdos_truncate` with a 2-byte string writes `.` unconditionally,
  where R:1F4D:050D compares the byte before the string with a space; `pdos_wrap_prepare` with `^`
  as the last character assumes a 0 after the terminator, where DOS continues into stale bytes of
  the DGROUP:BA06 buffer. Both depend on memory DOS does not define; the C picks a fixed answer.
* **O3 Scene stack (logic, not listing).** On `OBS_DLG_CREATE` only the topmost pending
  window-bound slot is considered, and a template that matches no row withdraws it
  (`pdos_scene.c:237..240`). A dialog function that first opens a message box of another template
  would lose its row. Not checked against the observer's event order; noted for D4b/D5 testing.
* **k = 2 ports** have no DOS counterpart; note only that the 1-pixel fill skip (G#39) there
  compares port-relative x, so a k = 1 port with a non-zero origin and its k = 2 twin can differ in
  that rule.

## Not reviewed

* `pdos_shadow.c` (not read), `pdos_compose.c` beyond `draw_elem`, `refresh_n`, `refresh_a`,
  `pdos_scene.c` beyond push/pop/dialog binding, `pdos_scene_tab.c` (141 rows), `pdos_fontmap.c`,
  `pdos_profile.c`, and the unit-test vectors themselves (since the code matches the listing in the
  functions traced, no test can be mirroring a misreading there; tests of the deviations F1..F3 do
  not exist).
* The fade progression (R:0000:050C/0631: steps, batch from the VGA calibration, per-pass weight
  increment, chunked DAC writes) and the dissolve's calibrated delay: area C's (D4b) per the design.
* G#9/G#15/G#30 (pointer in pages), G#22 (scaled sprite), G#16/17/23..27/33..36/50/51: not modelled
  by design (draft B 4.2), not reviewed.
* The scale `k = 2` paths beyond the remark above (no DOS reference to compare with).

Status: COMPLETE for priorities 1..5; priority 6 only partially (see above).

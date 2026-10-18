# DOS clock and presentation timing (extension phase D0, task D0-B)

Draft of 2026-10-11 for the DOS graphics profile. It records how the DOS program (the pinned
`CIV.EXE`, its overlays and the drivers it loads) keeps time, and every wait and interval of the
credits, the intro, Birth and palette cycling.

All timing here is **derived from the listing, not observed**. No DOS program was run and no
DOS-oracle (DOSBox) comparison was made. Seconds are computed from the listing's constants and
the PIT input clock. Revised on 2026-10-11 after review R1 (fixer F1,
`docs/verify/ext-d0-fixes-r1.md`): PIT ticks for the sound-tick durations, the shake setter's
number and smaller corrections.

Evidence labels: **DOS listing** (`build/dos/disasm/*.lst`, `db.json`), **DOS file** (read from
the DOS files in `build/dosdata` by my own decoding of bytes the listings do not cover: the sound
drivers, `EGRAPHIC.EXE`/`TGRAPHIC.EXE`, the root's far data), **PC knowledge** (general knowledge
of the 8253/8254 PIT, the 8259 PIC, the VGA, the BIOS and the Microsoft C run time; it carries a
conclusion only where marked), **inferred**, **unknown**. Address notation as in `BRIEF-d0.md`:
`R:ssss:oooo`, `O<n>:oooo`, `G:0000:oooo` (`MGRAPHIC.EXE`), `M:0000:oooo` (`MISC.EXE`),
`DGROUP:oooo` (= `R:2B01:oooo`). Driver functions: `G#n` (graphics), `M#n` (misc), `S#n` (sound,
slots 100+n at `R:0000:0A2B + 7n`).

Units used below:

* **clock**: one PIT input clock, 1/1,193,182 s (PC knowledge).
* **interrupt**: one IRQ0, a divisor's worth of clocks (the prompt's "PIT tick", 1,193,182 Hz
  divided by the divisor). In normal play ("slow mode") one interrupt is one frame, so a frame
  count is a PIT tick count; in "fast mode" a frame is `k` interrupts (section 2.5).
* **frame**: one call of the frame routine `R:0000:0345` (section 2.5). With retrace locking
  this is one vertical refresh period, `P` clocks. On VGA mode 13h `P` measures 17,024
  (70.086 Hz, PC knowledge for the 70.086 Hz refresh; the 17,024 follows from the arithmetic of
  `R:0000:0276`). Without locking `P` is 19,886 (60.001 Hz).
* **sound tick**: one call of sound driver function `S#3` (section 3.4). It is one frame, or six
  of every seven frames when the refresh is between 63.75 and 79.69 Hz. On VGA: 60.074 Hz. With
  the 60 Hz fallback: 60.001 Hz.
* **sound ticks as PIT ticks**: `NSOUND` never requests fast mode (its `S#3` returns 0), so one
  interrupt is one frame throughout. At the 60 Hz fallback every frame has a sound tick: n sound
  ticks are n PIT ticks. On VGA (`k` = 4) six of every seven frames have one, skipped by the
  free-running divider DGROUP:005E, whose phase the program does not set. So the n-th sound tick
  after a counter reset (`S#1`) falls on PIT tick n + floor((n−1)/6) or one later, and an
  interval of m sound ticks spans m + floor(m/6) to m + ceil(m/6) PIT ticks. Example: the logo
  wait's tick 3463 (section 5.3) is PIT tick 4,040 or 4,041 after the tune start, 57.64 or
  57.66 s at `P` = 17,024 clocks. The tables of section 5 give these values as "a/b" (a or b).

"@70" below means seconds at the VGA refresh (frames) or 60.074 Hz (sound ticks); "@60" means the
fallback clock (19,886 clocks per frame and per sound tick).

## 1. Summary of the clock

| Item | Value | Address | Label |
|---|---|---|---|
| Timer hardware | PIT channel 0, control word 36h (binary, mode 3 square wave, low then high byte) | R:0000:0023, R:0000:005C, R:0000:0258 | DOS listing; mode decoding PC knowledge |
| Divisor at install (calibration) | 0 = 65,536: 18.2065 Hz, 54.925 ms | R:0000:0023 | DOS listing |
| Divisor at exit (restore) | 0 = 65,536 | R:0000:005C | DOS listing |
| Divisor in normal play ("slow mode") | `P`, the measured refresh period in clocks: one interrupt per frame. VGA 17,024 (70.09 Hz) | R:0000:0258 (from DGROUP:0046) | DOS listing; VGA value inferred |
| Fallback divisor | 19,886 (60.001 Hz), when the measured rate is outside 45.5..79.7 Hz | R:0000:02E4 | DOS listing |
| Divisor in "fast mode" (requested by the sound driver) | floor(`P`/`k`), `k` = 4, 5 or 6 interrupts per frame. VGA: 4,256 (280.35 Hz); 60 Hz display: 3,977 (300.02 Hz) | R:0000:0077 | DOS listing; values inferred |
| Phase lock | every 20 frames the handler waits for the start of vertical retrace and restarts channel 0 | R:0000:0215 | DOS listing |
| BIOS chaining | the old INT 08h is called on average once per 65,536 clocks (18.2065 Hz) | R:0000:01C0..0210 | DOS listing |
| Frame counter | DGROUP:005C, word, +1 per frame | R:0000:0345 | DOS listing |
| Frame waits | `wait(n)` = R:0182:0134: clears the frame counter and polls until it reaches `n` | R:0182:0134 | DOS listing |
| Sound tick counter | in the sound driver, read by `S#5` (R:0000:0A4E); cleared by `S#1` (start tune) | e.g. NSOUND cs:0074 | DOS file |
| Palette work per frame | fade step (R:0000:0631), eight cycling slots (R:0000:044A), `G#51` | R:0000:0345 | DOS listing |
| Keyboard skip test | Microsoft C `kbhit` (INT 21h AH=0Bh) | R:2045:2098 | DOS listing; name PC knowledge |
| Mouse | never skips a presentation wait; the mouse handler does not feed the keyboard | R:0000:17DB | DOS listing (the handler, 26 instructions) |
| CPU speed | no presentation duration is a fixed instruction count; see section 4 for the exceptions | | DOS listing |

## 2. The INT 08h handler and PIT programming

### 2.1 Verification of the prompt's facts

| Load-module offset | What is there | Confirmed | Label |
|---|---|---|---|
| 0x23 | control word 36h to port 43h, then count 0 (low, high) to port 40h | yes, in R:0000:0000 (install) | DOS listing |
| 0x5C | the same, count 0 | yes, in R:0000:0051 (restore) | DOS listing |
| 0x258 | the same, count = DX = DGROUP:0046 | yes, in R:0000:0215 (resync) | DOS listing |
| 0x34 | INT 21h AH=35h AL=08h (get vector); result stored at cs:0211/0213 | yes | DOS listing |
| 0x44 | INT 21h AH=25h AL=08h (set vector) from the far pointer at cs:01A3 = R:0000:01A7 | yes | DOS listing |
| 0x6A | INT 21h AH=25h AL=08h with the saved pointer at cs:0211 | yes | DOS listing |

R:0000 is at load-module offset 0, so these offsets are R:0000:0023 etc. The saved old vector at
cs:0211 is the operand of the far jump at R:0000:0210, which the handler uses to chain
(self-modifying, **DOS listing**). Port 40h is also read at R:0000:032A/0330 (counter latch,
section 2.2). No other site reads or programs the PIT, and no site uses INT 1Ah or reads the
BIOS tick count at 0040:006C (**DOS listing**, search of all listings and `db.json`).

### 2.2 Install and calibration: R:0000:0000, R:0000:0276, R:0000:030B

Called once from `O2:01C3` (DS = DGROUP), after the graphics mode is set (`G#37` at `O2:0166`,
mode 13h in `MGRAPHIC`) and the sound driver is initialised (`S#0` at `O2:01BE`).

1. `R:0000:0000` sets the installed flag DGROUP:005A (byte; returns at once if it was already
   set), DGROUP:004C = 1, DGROUP:0054 = 1, clears the 32-bit accumulator DGROUP:0042/0044,
   programs divisor 65,536 (0x23), calls `R:0000:0276`, then reads and replaces the INT 08h
   vector (0x34, 0x44). **DOS listing**.
2. `R:0000:030B` (the measurement loop): with interrupts off, it polls port 3DAh until bit 3
   (vertical retrace) is clear, then until it is set, then latches channel 0 (control word 0 to
   port 43h) and returns the count. Each poll loop gives up after 65,535 reads and then returns
   0. It measures **the PIT count at the leading edge of vertical retrace**. **DOS listing**;
   bit meaning PC knowledge.
3. `R:0000:0276`, with interrupts off: sets DGROUP:0059 = 1, DGROUP:0058 = 1 (retrace locking
   on), calls `030B` once, then 16 more times, adding each difference (previous count minus new
   count, 16-bit) into the 32-bit sum DGROUP:0050/0052. So it times 16 refresh periods.
   * The sum is added to the BIOS-chaining accumulator DGROUP:0042/0044 (R:0000:02AD). **DOS
     listing**. Inferred: this credits the BIOS clock for the ticks lost while interrupts were
     off. In mode 3 the counter steps by two per clock (PC knowledge), so the credit is about
     twice the elapsed time (about four extra BIOS ticks, 0.2 s; **inferred**).
   * `P` = sum / 16, then halved (R:0000:02B5..02BC): the halving converts mode-3 counter units
     to clocks (**inferred** from PC knowledge of mode 3). `P` is stored at DGROUP:0050.
   * `k` = floor((`P` + `P`/16) / 3977) (R:0000:02BF..02D0). 3977 clocks is 1/300.02 s. If `k`
     is 4, 5 or 6 it is kept; otherwise retrace locking is switched off (DGROUP:0058 = 0), `P` =
     19,886 (60.001 Hz) and `k` = 5 (R:0000:02DF..02EA). `k` is stored at DGROUP:004E.
     **DOS listing**.
   * Ranges (computed from the arithmetic): `k` = 4 for `P` in 14,973..18,715 (79.69..63.75 Hz),
     5 for 18,716..22,458 (63.75..53.13 Hz), 6 for 22,459..26,201 (53.13..45.54 Hz). VGA mode 13h
     (70.086 Hz, PC knowledge) gives `P` = 17,024, `k` = 4 (**inferred**).
   * DGROUP:0048 = DGROUP:0046 = `P` / DGROUP:004C = `P` (DGROUP:004C is 1 here; the branch at
     R:0000:02F0 that would set it to `k` is not taken on this path). **DOS listing**.
4. The PIT keeps the 65,536 divisor until the first resync (section 2.4). DGROUP:0059 = 1 makes
   that happen at the first frame, that is at the first interrupt. **DOS listing**. If that
   first interrupt already falls inside retrace, nothing is reprogrammed (the divisor equals the
   target and no wait was needed) and 65,536 stays for 20 more interrupts, about 1.1 s
   (**inferred** from the code; rare, the retrace pulse being a small part of the frame).

Failure behaviour: if no retrace is seen, `030B` returns 0, the differences are 0, `k` = 0 and
the 60 Hz fallback without locking is used (**DOS listing**). The 65,535-read timeouts are a
CPU/bus-speed assumption (section 4).

### 2.3 The handler: R:0000:01A7

Entered from IRQ0 through the vector set at install. **DOS listing** unless marked.

1. Saves AX, BX, CX, DX, DS; switches to a private stack (SS = R:0000, SP = 01A1; the 256 zero
   bytes R:0000:00A1..01A0); enables interrupts (`sti`); DS = DGROUP.
2. Adds the current divisor DGROUP:0048 to the 32-bit accumulator DGROUP:0042 (low) / 0044
   (high).
3. Decrements DGROUP:0054. When it reaches 0: reloads it from DGROUP:004C (interrupts per
   frame), calls the resync `R:0000:0215`, then the frame routine `R:0000:0345`.
4. If DGROUP:004C is not 1 (fast mode): calls `S#4` (R:0000:0A47) on every interrupt.
5. If the high word DGROUP:0044 is 0: non-specific EOI (20h to port 20h), restore, `iret`.
   Otherwise: decrements DGROUP:0044, restores, `cli` and jumps far to the old vector (the BIOS
   handler then sends its own EOI: PC knowledge).

So the old handler runs once per 65,536 accumulated clocks: 18.2065 Hz on average, at frame
interrupts, irregularly spaced (on VGA every 3 or 4 frames). The BIOS time of day, the diskette
motor time-out (used by `G#10`, section 3.7) and DOS time keep running (**inferred** from PC
knowledge of the BIOS handler). While the handler runs, IRQ0 is in service and the 8259 blocks
the keyboard and mouse interrupts until the EOI (PC knowledge), so the frame work delays them.

The handler is not re-entrant (fixed private stack). The accumulator adds the programmed divisor
even for the first interrupts, when the PIT still runs at 65,536 (a small under-credit,
**inferred**).

### 2.4 Retrace resync: R:0000:0215

Called from the handler once per frame. **DOS listing** unless marked.

* DGROUP:0059 (byte) counts frames down; at 0 it is reloaded with 20 and the resync runs. So the
  resync runs every 20 frames (0.285 s @70), and on the next frame after DGROUP:0059 is set to 1
  (install, mode switches).
* If locking is on (DGROUP:0058 non-zero) it busy-waits inside the interrupt until port 3DAh
  bit 3 (vertical retrace) is set. While waiting it counts changes of bit 0 (display enable) in
  CX, starting from 0 (`xor cx, cx` at R:0000:0222, `loop` at R:0000:023E). After 65,536 changes
  without retrace it switches locking off (DGROUP:0058 = 0) and returns.
  The loop has no exit if bit 0 never changes and retrace never comes (**inferred** hang risk on
  hardware or emulators that do not toggle bit 0).
* Then, if the target divisor DGROUP:0046 differs from the current DGROUP:0048, or it waited at
  least one change (CX not 0), it stores DGROUP:0046 into DGROUP:0048, reprograms channel 0
  (R:0000:0258; writing the control word restarts the count, PC knowledge), increments the
  reprogram count DGROUP:004A and stores the number of changes waited in DGROUP:0056. If it was
  already inside retrace with the same divisor, nothing is reprogrammed.
* Effect (**inferred**): the interrupt is phase-locked to the start of vertical retrace. The
  truncations in `R:0000:0276` make `P` at most the true period, so interrupts drift slightly
  early and each resync waits a few microseconds. The frame rate is the display's refresh rate,
  not `P`'s nominal rate. DGROUP:004A and DGROUP:0056 have no readers in the listings
  (diagnostics, **DOS listing**).

### 2.5 The frame routine: R:0000:0345

Runs inside the handler once per frame, DS = DGROUP, in this order. **DOS listing**.

1. Increments the frame counter DGROUP:005C (16-bit, wraps).
2. `R:0000:0631`: one palette-fade step (section 3.5).
3. `R:0000:044A`: palette cycling, eight slots (section 3.6). It runs after the fade step, so a
   cycling range overrides the fade's writes in the same frame.
4. `G#51` (R:0000:08D4 → G:0000:10BB): advances a driver-private generator (cs:10AC =
   cs:10AC × 5 + 1) and, while the byte cs:10AE is non-zero, writes CRTC register 0Dh (start
   address low) with 0..3 from it and counts cs:10AE down (screen shake). cs:10AE is set only by
   `G#29` (G:0000:10AF, slot R:0000:083A = 076F + 7·29), which has no callers in the listings, so
   the shake is inactive (**DOS listing**; unknown whether an unresolved path sets it).
5. If `k` (DGROUP:004E) is 4: the byte DGROUP:005E (initial 7, **DOS file**) is decremented and,
   when it reaches 0, reset to 7 and the routine returns without step 6. So step 6 runs six of
   every seven frames: 60.074 Hz on VGA. **Inferred**: this keeps the music at about 60 Hz on
   70 Hz displays.
6. `S#3` (R:0000:0A40), the sound tick. Its return value requests a timer mode: positive →
   `R:0000:0077` (fast mode: DGROUP:004C = `k`, DGROUP:0046 = `P`/`k`, DGROUP:0059 = 1);
   negative → `R:0000:008F` (slow mode: DGROUP:004C = 1, DGROUP:0046 = `P`, DGROUP:0059 = 1);
   zero → no change. The new divisor takes effect at the next frame's resync.

Mode switches do not change the frame rate: a frame stays `P` clocks (`k` × floor(`P`/`k`) in
fast mode, at most `k`−1 clocks shorter, re-locked every 20 frames). **Inferred** from the
arithmetic.

### 2.6 Restore: R:0000:0051

Called from `R:01A8:019C` at exit, after `S#2` (R:01A8:0197). If the installed flag DGROUP:005A
was set it clears it, programs divisor 65,536 (0x5C) and restores the saved vector (0x6A).
**DOS listing**.

## 3. Counters and wait primitives

### 3.1 Variables

| Address | Width | Meaning | Written by | Read by | Label |
|---|---|---|---|---|---|
| DGROUP:0042 / 0044 | 2 words (32-bit) | clocks accumulated toward the next BIOS chain; high word = chains pending | 0000, 01A7, 0276 | 01A7 | DOS listing |
| DGROUP:0046 | word | target divisor | 0077, 008F, 0276 | 0215 | DOS listing |
| DGROUP:0048 | word | programmed divisor | 0215, 0276 | 01A7, 0215 | DOS listing |
| DGROUP:004A | word | count of resync reprogrammings | 0215 | none | DOS listing |
| DGROUP:004C | word | interrupts per frame (1, or `k` in fast mode) | 0000, 0077, 008F | 01A7, 0276 | DOS listing |
| DGROUP:004E | word | `k` | 0276 | 0077, 0345 | DOS listing |
| DGROUP:0050 / 0052 | word (+ word) | calibration sum, then `P` | 0276 | 0077, 008F | DOS listing |
| DGROUP:0054 | word | interrupts left in this frame | 0000, 01A7 | 01A7 | DOS listing |
| DGROUP:0056 | word | display-enable changes waited at the last resync | 0215 | none | DOS listing |
| DGROUP:0058 | byte | retrace locking on | 0215, 0276 | 0215 | DOS listing |
| DGROUP:0059 | byte | frames until resync (reload 20) | 0077, 008F, 0215, 0276 | 0215 | DOS listing |
| DGROUP:005A | byte | timer installed | 0000, 0051 | 0000, 0051 | DOS listing |
| DGROUP:005C | word | frame counter | 0345, 033E | 033A, 033E | DOS listing |
| DGROUP:005E | byte | 7-frame divider (initial 7) | 0345 | 0345 | DOS listing, DOS file |
| DGROUP:0060..006C | words | palette fade state (section 3.5) | 050C, 05B7, 0573, 0631 | 0631, 05B7 | DOS listing |
| R:25CF:0000..0012, 0014 + 66h·i | words, 8 records of 102 bytes | palette cycling (section 3.6) | 0382, 03FA, 042B, 044A | 044A | DOS listing |

All "Written by / Read by" entries are R:0000 routines. The timer variables DGROUP:0042..005E are
accessed only by R:0000:0000..0382 (search of all listings for these offsets; **DOS listing**).
C code reaches the frame counter only through R:0000:033A and R:0000:033E.

DS check: the handler loads DS = 2B01 (relocated, R:0000:01BB). `0000`, `0051`, `0276`, `033A`,
`033E`, `04AA`, `04D4` are called from Microsoft C code with DS = DGROUP; `0077`, `008F`, `0215`,
`0345`, `0631` run inside the handler with DS = DGROUP. `0382`, `03FA`, `042B`, `044A` load
DS = 25CF (relocated). **DOS listing**.

### 3.2 Frame counter readers

| Routine | Contract | Label |
|---|---|---|
| R:0000:033A | Returns AX = DGROUP:005C. No side effects. | DOS listing |
| R:0000:033E | Returns AX = DGROUP:005C and sets it to 0 (one `xchg`, atomic against the handler). | DOS listing |

Callers: `R:0182:0134` (wait), `O2:0334` (intro), `O2:0BD7` (space sequence), `O7:17CF`
(Birth), `O9:0F79`, `O19:167B`, `O19:18C1`, `O19:1AE1`, `O22:0EAF` (other sequences, section
5.8). **DOS listing**.

### 3.3 `wait(n)`: R:0182:0134

* Input: `n`, signed word (first argument).
* Effect: calls R:0000:033E (frame counter := 0), then calls R:0000:033A until the counter is
  not less than `n` (signed compare).
* Duration: returns just after the `n`-th frame routine after the call: more than `n`−1 and at
  most `n` frames, `n`·`P` clocks at most. With locking, it returns right after a retrace starts
  (**inferred**). `n` ≤ 0 returns at once.
* Side effect: it clears the shared frame counter, so it disturbs any caller that measures with
  R:0000:033A across it (for example the Birth "BUILDING NEW WORLD..." blink, section 5.5).
* No key or mouse test: a `wait` is never skipped by input. Callers test `kbhit` between waits.
* Failure: none; if the timer is not installed the counter never moves and `wait(n)` with `n` > 0
  never returns (**inferred**; the timer is installed before the first use).
* **DOS listing**; duration **inferred** from the handler.

### 3.4 Sound tick: `S#1`, `S#3`, `S#5`

The intro, the title menu and Birth use the sound driver's tick counter as their clock. Sound is
out of scope, so only the counter is recorded here. Driver tables decoded from the DOS files
(header word 30h = 11 functions at word offsets from 32h, as `BRIEF-d0.md` describes):

| Driver | Counter | `S#1` (start tune `n`) | `S#3` (tick) | `S#5` | Label |
|---|---|---|---|---|---|
| NSOUND.CVL ("no sound") | cs:0074 | clears it (no range check) | +1, returns 0 | returns it | DOS file |
| ISOUND.CVL | cs:0048 | clears it after starting tune `n` ≤ 44 | +1 (via cs:0280), returns a mode request | returns it | DOS file |
| TSOUND.CVL | cs:00F5 | clears it (cs:00E5) | +1, returns 0 | returns it | DOS file |
| ASOUND.CVL | cs:0E0C | clears it (cs:1D9C) | +1 only on one path (cs:117F; skipped when its word 741Ah is FFFFh) | returns it | DOS file |
| RSOUND.CVL | cs:0059 | clears it (cs:0D84) | +1 only when its word 66h is 0 (cs:01B7) | returns it | DOS file |

`R:01A8:046C(n)` calls `S#1(n)` only if bit 10h of DGROUP:19C0 (sound on) is set (**DOS
listing**). `O2:031C` sets that bit before the intro tune; key code 2F00h in menus (Alt+V, PC
knowledge) toggles it and stops the tune when it turns sound off (R:1D05:039A). The driver
chosen at start-up (default `nsound.cvl`, name at DGROUP:1A30, first letter rewritten by O1)
decides the counter. With NSOUND, ISOUND and TSOUND the counter is the sound tick of section 2.5
step 6 (**DOS file**). With ASOUND and RSOUND it can stop (meaning of the condition
**unknown**); the intro loops of section 5.3 that wait on it have no time-out. The semantics of
tune numbers (1 is used after every sequence, **inferred**: silence) are out of scope.

### 3.5 Palette fade: R:0000:04AA, R:0000:04D4

* `R:0000:04AA(steps, pal)`: copies 768 bytes from `pal`+6 to DGROUP:BA06 (the target),
  snapshots the DAC, starts the fade and busy-waits until it ends. `R:0000:04D4(steps, r, g, b)`:
  the same with 256 copies of (r, g, b) as the target. **DOS listing**.
* `R:0000:0554`: with interrupts off, waits for vertical retrace (no time-out), reads all 256 DAC
  entries into DGROUP:BD06. **DOS listing**.
* `R:0000:050C`: frames `F` = 6 × (low byte of `steps`) → DGROUP:0068. On the first fade only it
  measures (R:0000:0573) how many DAC entries can be written, in groups of 10, between the end of
  one vertical retrace and the start of the next (interrupts off; about 1..2 frames), caching the
  count `M` in DGROUP:0066. Entries per frame `E` = min(256, `M`/14) → DGROUP:0064. Passes over
  the palette `p` = floor(`E`·`F`/256); weight step = floor(65,536/(`p`−1)) → DGROUP:006A/006C.
  **DOS listing**.
* Each frame (`R:0000:0631`, in the frame routine): if DGROUP:0068 is non-zero, writes the batch
  of `E` entries prepared by `R:0000:05B7` to the DAC from index DGROUP:0062, decrements
  DGROUP:0068 and prepares the next batch. A batch entry is round((start·(65,535−t) +
  target·t)/65,536) per component; the weight `t` advances by the step after each full pass and
  saturates at 65,535. **DOS listing**.
* Duration: **`F` = 6·steps frames**, (6·steps−1, 6·steps] frames from the call, plus the
  retrace wait in `0554` (up to 1 frame) and, on the first fade, the measurement (up to about 2
  frames). It does not depend on CPU speed; the smoothness does (`E`). Not skippable.
* Failure: when 256 ≤ `E`·`F` < 768 (`p` = 1 or 2) the division at R:0000:0544 overflows
  (divide error); when `E`·`F` < 256 (`p` = 0) the weight step is 1 and the palette hardly
  moves. `M` < 14 gives `E` = 0 and a 65,536-iteration batch loop. All **inferred**, not
  observed; with the shortest fade in the program (5 steps, 30 frames) they need `E` < 26, far
  below what VGA hardware gives.
* Remark: DGROUP:BA06 is also the program's common text buffer, and the start of the picture
  decoder's dictionary DGROUP:BA06..D205 (2,048 three-byte entries), which every `.PIC` decode with
  a non-zero width or height resets (R:0000:1227 falling into 1270..1291; FORMATS.md 1.3,
  PALETTE.md 2.6); a fade and a picture load both overwrite it. For the
  Birth palettes the first entry is black, so the text length test after a fade (O7:1B29) reads 0
  (**DOS file**; no timing effect).

### 3.6 Palette cycling: R:0000:0382, R:0000:03FA, R:0000:042B, R:0000:044A

Data in segment R:25CF: word 0000 (`rep outsb` allowed, section 4), eight near pointers at
0002..0011, FFFFh at 0012, eight records of 102 bytes at 0014 + 66h·i. Record: +0 word step
(±3 bytes), +2 word offset, +4 word length in bytes (3 × count), +6 byte first DAC index, +7
byte `rate`, +8 byte countdown (0 = stopped), +9 colours (the range once, then again minus one
entry). **DOS listing**.

| Routine | Contract | Label |
|---|---|---|
| R:0000:0382(slot, rate, lo, hi) | slot 1..8 (else nothing). If hi ≤ lo (unsigned) nothing. Count = min(hi−lo+1, 16). Reads the current DAC entries lo.. (interrupts off) into the record, stores the low byte of `rate` (R:0000:03E9: a `rate` of 300 is stored as 44), stops the slot. | DOS listing |
| R:0000:03FA(s) | slot \|s\|; step = +3 if s > 0, −3 if s < 0; countdown := `rate` (starts it; `rate` 0 leaves it stopped). | DOS listing |
| R:0000:042B(slot) | countdown := 0 (stops it; the DAC keeps the last colours). | DOS listing |
| R:0000:044A | per frame, for each record with a non-zero countdown: decrement; at 0 reload `rate`, move the offset by the step (wrapping) and write the `count` entries to the DAC from index lo. | DOS listing |

Timing: a running slot rotates its range by one entry every **`rate` frames** (`rate`·`P`
clocks), the first step `rate` frames after `03FA`. Each step subtracts the step from the offset
(R:0000:0477, then the wrap at 0479..0484) and writes `count` entries from the new offset to
the DAC from index lo (0484..04A1), so with s > 0 (step +3) the window into the colour list moves
back one entry and each colour moves to the next higher DAC index (**DOS listing**,
R:0000:0471..04A1).
Paced by the frame routine only; no
CPU dependence. `R:1DC4:0626` / `R:1DC4:065F` start / stop slots 1..3 only on VGA (DGROUP:D762)
and track the state in DGROUP:2FEC. **DOS listing**.

### 3.7 Other timed primitives

| Routine | Contract and timing | Label |
|---|---|---|
| G:0000:01A1 (used by `G#27`, `G#28` = palette set from data or from a picture's palette) | Waits for vertical retrace (no time-out), writes entries while retrace lasts, counting them (`n`); when retrace ends it writes 13·`n` more without testing, then waits for the next retrace. A palette load therefore takes the retrace wait plus about count/(14·`n`) frames. | DOS listing (G:0000:01B2..01EB, DRIVER.md G#26..28); duration inferred |
| G:0000:01ED (`G#27` overscan) | waits for retrace, sets the attribute controller's overscan colour | DOS listing |
| G:0000:051C, G:0000:0536 (`G#23`, `G#24`) | wait for retrace, then screen off / on; their slots have no callers | DOS listing |
| `G#10` = G:0000:06B7(page, `c`) (dissolve) | First waits for a BIOS tick: writes 1 to 0000:0440 (BIOS diskette motor count) and polls until it changes (≤ one chained tick, 54.9 ms; PC knowledge for the BIOS decrement). On first use calibrates (G:0000:0776, G:0000:07A4, interrupts off): `n1`, `n17` = pixels copied in one interval from the end of a vertical retrace to the start of the next with an inner delay of 1 and 17. Then copies the 64,000 pixels of `page` to the screen in the order of a 16-bit LFSR (0B400h) with an inner delay loop `d` per pixel, `d` = round((`n1`−`n`)·256·`n17`/(`n1`−`n17`)/(16·`n`)) + 1, `n` = 8,800/`c` pixels per interval. If `c` = 0 or `n` ≥ `n1` there is no delay. Intended duration (**inferred**): 64,000·`c`/8,800 = 7.27·`c` intervals; on VGA an interval is about 447/449 frame (PC knowledge), so about 0.103·`c` s. Interrupts stay enabled during the copy, so the frame work makes it longer than calibrated (**inferred**). Not skippable. | DOS listing; durations inferred |
| R:2045:2098 (`kbhit`) | INT 21h AH=0Bh (or a pushed-back character); does not consume the key. | DOS listing; name PC knowledge |
| R:0403:4545 | reads keys while `kbhit` (through `R:1D05:0AC9`, `M#1` = INT 16h AH=0), then loops until no mouse button is down or was pressed (DGROUP:DB3A via R:01A8:0223). Untimed. | DOS listing |
| R:1FA1:01A2 (picture loader) → R:0000:108E | calls `G#28` (R:0000:0833) at R:0000:1096 and R:0000:112D; a palette applied there goes through G:0000:01A1 above (when exactly is not traced); no other wait | DOS listing; inferred |
| R:1DC4:0042 | `srand(time())`: time from INT 21h AH=2Ah/2Ch (R:2045:25E6). The only use of the DOS clock. | DOS listing |

## 4. CPU-speed assumptions

No presentation duration of the credits, intro, Birth or palette cycling is a fixed count of
instructions. Their clocks are the frame routine (the display refresh, measured and phase-locked
through the PIT) and the sound tick derived from it. The sites that do depend on CPU or bus
speed:

| Site | Dependence | Effect | Label |
|---|---|---|---|
| R:0000:030B | 65,535 polls of port 3DAh per edge | time-out of the calibration (about 65 ms at 1 µs per port read, PC knowledge); a much faster bus would make it miss a 70 Hz frame and fall back to 60 Hz without locking | DOS listing; effect inferred |
| R:0000:0215 | counts display-enable changes (hardware-paced) | time-out after 65,536 changes; no CPU dependence | DOS listing |
| R:0000:0573 | DAC writes in one display interval | fade batch size `E` (smoothness; divide-error risk) | DOS listing |
| G:0000:01A1 | DAC writes per retrace | frames taken by a palette load | DOS listing |
| G:0000:0776/07A4 (and `G#10` of EGRAPHIC at 105E, TGRAPHIC at 0E74, same scheme, constant 0x271F = 10,015 in TGRAPHIC) | calibrated busy loop | dissolve duration approximately constant, not exact | DOS listing; DOS file for E/T |
| O2:0476, O2:07D0 (intro pan), O2:10A9 (space pan) | catch-up: when behind the clock, an odd column is skipped | slow CPUs drop columns, the clock is kept | DOS listing |
| O7:17CF (Birth) | runs only when world generation calls it | events are never early; on a slow CPU they can be late | DOS listing; inferred |
| M:0000:00C4 (joystick read, `M#5`/`M#6`) | counting loop on port 201h | calibrated per axis; the slots R:0000:0A0F/0A16 have no callers | DOS listing |
| I/O delays (`jmp` to the next instruction after port writes, e.g. R:0000:0027) | bus recovery | negligible | DOS listing; meaning PC knowledge |

CPU **type** (not speed) is tested at R:0000:038D and R:0000:0573: AX = FFFFh shifted right by
CL = 32 is 0 on an 8086/8088 and FFFFh on later CPUs, which mask the count (PC knowledge). The
result (R:25CF:0000, DGROUP:0060) selects `rep outsb` (80186 and later) or a byte loop for DAC
writes. **DOS listing**.

## 5. The sequences

### 5.1 Start-up order

`R:01A8:0008` (main): load `misc.exe`; `O1:0000`; keyboard flags (0040:0017 bit 5 cleared);
Ctrl-Break and Ctrl-C handlers replaced (R:01A8:03F4); `O2:0000` (drivers, timer, intro,
credits, logo); memory check; `R:01A8:0486` (title menu; New Game, EARTH and Customize continue
into `O7:0012`, which runs Birth); `R:01A8:087C`; the game loop `R:0238:0092`; at exit `S#2` and
the timer restore. **DOS listing**.

`O1:0000` reads `intro.txt` and asks text-mode questions (graphics, sound, input) with blocking
key reads (`M#2` = INT 21h AH=01h). It has no timed waits (**DOS listing**).

### 5.2 Before the intro (O2:0000 up to O2:0345)

Untimed: the disk check loop (O2:003A..00EB, "Please insert Disk 1" waits for a key,
R:2045:20AC = INT 21h AH=08h), driver loading, mode set, page allocation, `S#0`, timer install
(O2:01C3, section 2.2: 17 frame periods with interrupts off, about 0.25 s @70), `srand`, loading
`logo.pic`, `birth0.pic` (page 1) and `birth1.pic` (page 2) and the `logo.pic` palette (through
`G#28`, retrace-paced). Palette cycling slot 1 is set up with `rate` 14 for DAC 146..152 and, on
VGA, slots 1..3 are started (**DOS listing**); slots 2 and 3 still hold their initial `rate` 0
(**DOS file**, R:25CF records) and stay stopped.

### 5.3 Intro and credits: O2:0345..O2:0BD6

At O2:0334 the frame counter is cleared, at O2:0339 the tune 3 starts (`S#1(3)`, sound tick
counter := 0). All times below are sound ticks from that moment. Credits are the 24 lines of
`credits.txt` (opened in text mode, O2:0329), read one per cue by `O2:19A3` (`fscanf` of one
line, **DOS listing**; 24 lines then Ctrl-Z, **DOS file**).

The pan is two loops over the column `x` = 0..319 (`[bp-48h]`): loop A (O2:034A..0632, page 1)
and loop B (O2:0635..09D4, pages 1 and 2). Per column: credit cue test, text drawn in three
layers if the line is not empty, pan blits, then the clock test:

* catch-up (O2:0476 / O2:07D0): if floor(21·`x`/4) (loop B: floor((21·`x`+6720)/4)) is below the
  tick and `x` is even, `x` is incremented (one odd column skipped);
* wait (O2:04A0..04BF / O2:07FD..0828): polls `S#5` until the tick reaches that value. 21/4 =
  5.25 ticks per column (87.4 ms @70). Loop A has no key test inside the wait; loop B tests
  `kbhit` on every poll;
* key (O2:04C1 / O2:082A): if `kbhit`, `x` := 999 (the loop ends).

All cue columns are even, so catch-up never skips a cue. A cue at column `x` runs right after
the wait of column `x`−1: at tick floor(21(`x`−1)/4) (loop B + 6720 inside the floor).

PIT ticks are counted from the tune start; at the 60 Hz fallback they equal the sound ticks
(units section).

| Cue | Loop, x | Address | Event | Sound tick ≥ | PIT tick @70 | s @70 | s @60 |
|---|---|---|---|---|---|---|---|
| 0 | A, 0 | O2:034A | pan starts, no text | 0 | 0 | 0.00 | 0.00 |
| 1 | A, 10 | O2:0522 | word +10h of the drawing context at DGROUP:[00AA] := 5 (the font number, DRIVER.md 3.2); credit line 1 | 47 | 54/55 | 0.78 | 0.78 |
| – | A, 50 | O2:053C | text cleared | 257 | 299/300 | 4.28 | 4.28 |
| 2 | A, 70 | O2:0547 | line 2 | 362 | 422/423 | 6.03 | 6.03 |
| 3 | A, 120 | O2:0558 | line 3 | 624 | 727/728 | 10.39 | 10.40 |
| – | A, 160 | O2:0569 | cleared | 834 | 972/973 | 13.88 | 13.90 |
| 4..11 | A, 170, 190, ..., 310 (every 20) | O2:0575..05F3 | lines 4..11 | 887, 992, 1097, 1202, 1307, 1412, 1517, 1622 | 1034/1035, 1157/1158, 1279/1280, 1402/1403, 1524/1525, 1647/1648, 1769/1770, 1892/1893 | 14.77 .. 27.00 | 14.78 .. 27.03 |
| – | A end | O2:04D2 | last wait of loop A (x = 319) | 1674 | 1952/1953 | 27.87 | 27.90 |
| 12 | B, 10 | O2:089F | line 12 | 1727 | 2014/2015 | 28.75 | 28.78 |
| 13 | B, 30 | O2:08B0 | line 13 | 1832 | 2137/2138 | 30.50 | 30.53 |
| – | B, 50 | O2:08C1 | cleared | 1937 | 2259/2260 | 32.24 | 32.28 |
| 14 | B, 64 | O2:08CC | line 14 | 2010 | 2344/2345 | 33.46 | 33.50 |
| 15 | B, 84 | O2:08DD | line 15 | 2115 | 2467/2468 | 35.21 | 35.25 |
| – | B, 116 | O2:08EE | cleared | 2283 | 2663/2664 | 38.00 | 38.05 |
| 16..24 | B, 130, 150, ..., 290 (every 20) | O2:08F9..0989 | lines 16..24 | 2357, 2462, 2567, 2672, 2777, 2882, 2987, 3092, 3197 | 2749/2750, 2872/2873, 2994/2995, 3117/3118, 3239/3240, 3362/3363, 3484/3485, 3607/3608, 3729/3730 | 39.23 .. 53.22 | 39.28 .. 53.28 |
| – | B, 310 | O2:099B | cleared | 3302 | 3852/3853 | 54.97 | 55.03 |
| – | B end | O2:083B | last wait of loop B (x = 319) | 3354 | 3912/3913 | 55.83 | 55.90 |

After the pan (DOS listing unless marked):

| Step | Address | Primitive and argument | Duration | Skip | Confidence |
|---|---|---|---|---|---|
| Shortcut key | O2:09D7..0A51 | if `kbhit`: read the key; N/L/E/C (either case) preselect the menu item 0..3 in DGROUP:6B32, any other key leaves -1; the logo steps below are skipped | none | – | DOS listing |
| Wait for the logo | O2:0A19..0A23 | polls `S#5` until tick ≥ 0D87h = 3463 | until PIT tick 4040/4041 @70 (3463 @60) after the tune start, 57.65 s @70 (57.72 s @60); from the end of loop B 109 ticks (127/128 PIT ticks @70, 1.81 s) | no (no key test) | DOS listing |
| Logo set-up | O2:0A53..0AB1 | full-screen copy; logo sprite drawn on page 1; VGA: slot 4 = DAC 224..239, `rate` 14, started | untimed | – | DOS listing |
| Logo reveal | O2:0AB4..0AF4 | 80 iterations: copy a 4-column strip, `wait(1)` | 80 frames: 1,361,920 clocks @70 (`80·P`), 1.141 s @70, 1.333 s @60 | no | DOS listing; duration inferred |
| Logo hold | O2:0AF6..0B19 | up to 100 × `wait(5)`, `kbhit` tested before each | ≤ 500 frames: 8,512,000 clocks @70, 7.134 s @70, 8.333 s @60 | key, at the next 5-frame boundary | DOS listing |
| Key flush | O2:0B1B | R:0403:4545 | untimed (until mouse buttons released) | – | DOS listing |
| Cycles off | O2:0B26..0B48 | VGA: slots 1..4 stopped | – | – | DOS listing |
| Dissolve | O2:0B52..0B90 | page 1 cleared, logo drawn, `G#10(1, 20)` | ≤ 1 BIOS tick + calibration (first use) + about 145 intervals: about 2.07 s @70 | no | inferred (section 3.7) |
| Show | O2:0B93..0BCF | full copy to the screen, `G#31(0)`, sprite freed | untimed | – | DOS listing |

Totals without a key (**inferred**): from the tune start about 57.6 + 1.1 + 7.1 + 2.1 = 68 s on
VGA (about 69.8 s at the 60 Hz fallback, where the reveal and hold are longer). A key during the
pan ends the current loop at the next column; loop B then draws one column and ends at once
(the key is still pending), and the steps from "Wait for the logo" to "Key flush" are skipped
(O2:0A0F..0A16 jumps to O2:0B26 unless DGROUP:6B32 is −2, that is no key was read); "Cycles off" (O2:0B26..0B48) and the
dissolve still run. The tune keeps playing into the menu. Corrected 2026-10-11 (D1 decision
C.20-6, `docs/verify/ext-d1-draft-C.md` C.6.2): the earlier text skipped "Cycles off" as well.

### 5.4 Title menu hand-off: R:01A8:0486, R:1D05:0031

| Step | Address | Primitive and argument | Duration | Skip | Label |
|---|---|---|---|---|---|
| Menu | R:01A8:0494 | popup menu R:0238:0008 → R:1D05:0031, unless a shortcut was taken in the intro | until a choice | – | DOS listing |
| Choice hold | R:1D05:0441 | `wait(20)` after a confirmed choice (all popup menus; on EGA/Tandy after redrawing the bar) | 20 frames: 340,480 clocks @70, 0.285 s @70, 0.333 s @60 | no | DOS listing |
| Phrase boundary | R:01A8:04C2..04DA | polls `S#5`: if the tick is above 1495h = 5269, waits until (tick − 5269) is a multiple of 120h = 288 | 0 if the tune has run ≤ 5269 ticks (PIT tick 6147/6148 @70, 87.71 s @70); else up to 287 ticks (at most 335 PIT ticks @70, 4.78 s @70; 287 PIT ticks, 4.78 s @60) | no | DOS listing; purpose inferred (end the tune on a phrase) |
| Tune off | R:01A8:04E1 | `S#1(1)` | – | – | DOS listing |
| Customize only | R:01A8:05B6 | VGA: `R:0000:04D4(5, 0, 0, 0)` fade to black | 30 frames: 510,720 clocks @70, 0.428 s @70, 0.500 s @60 | no | DOS listing |
| After setup (New Game, EARTH, Customize) | R:01A8:0840 | VGA: fade to black, 5 steps, after `O5:1455` | 30 frames | no | DOS listing |

The tick counter keeps counting from the intro's `S#1(3)` through the menu. The compare at
R:01A8:04CA is signed: after 32,767 ticks (9.1 min) it no longer waits (**inferred**).

### 5.5 Birth: O7:17CF

Birth runs for New Game (`R:01A8:052E`), Customize (the same call, through the jump at
`R:01A8:0792`) and EARTH (`R:01A8:079F`). `O7:17CF` is a step function: world generation
(`O7:0012` and the stages `O7:065C`, `O7:0A33`, `O7:1440`) calls it from 12 sites: 11 in its
generation loops (O7:0055 .. O7:1724) and O7:05A1 in the loop after generation. Each call either
returns at once (event not due) or performs one story event with its waits inline.
After world generation `O7:059A` sets DGROUP:67FC = 1 (story skippable) and `O7:05A0..05A6` calls
it until it returns 0. For EARTH the stages before `O7:0A33` are skipped (O7:003A). **DOS listing**.

State (DGROUP, **DOS listing**; initial values **DOS file**): 3B62 state (0 = not started, 1 =
running, 2..5 = finished, initial 0); 3B64 next picture number (initial 1); 3B66 offset into the
cycle table; 3B68 slots in use; 6800 "now" (sound tick); 6802 text lines shown; 6804 the
`story.txt` stream (text mode, "rt"); 6806 the due tick (and a weight `w` while an event runs).

Clock and schedule (**DOS listing**):

* "now" = `S#5` at the start of the call, but only once a text line has been shown
  (DGROUP:6802 ≠ 0); before that it is 0.
* If now < due the call returns 1 (O7:18B0).
* The first text line (O7:19AB) clears the frame counter, calls `S#1(1)` then `S#1(4)`: tune 4
  starts and the tick counter restarts at 0. Birth's ticks are counted from here.
* After each event: due = clamp(`T`[`m`], now + 45·`w`, 32767) (R:1DC4:007C = clamp, signed),
  where `m` = DGROUP:6802 after the event, `T` = the word table at R:2710:0083 (45 words, the
  last FFFFh; **DOS file**, values decoded only into `build/dos/scratch-d0b/birth-schedule.txt`),
  `w` = 2 for a text line, 3 for a text line longer than 19 characters, 0 for a picture line.
  So `T`[`m`] is the music tick at which the next event may start, and a text line stays at
  least 90 ticks (105 PIT ticks @70, 1.50 s) or 135 ticks (157/158 PIT ticks @70, 2.25 s); at
  the 60 Hz fallback the PIT ticks equal the sound ticks. The last text line is due at 8,512
  ticks (the last entry before FFFFh, **DOS file**), PIT tick 9930/9931 @70 (8,512 @60), about
  142 s after tune 4 starts; the end follows at least 90 ticks later, then `wait(180)`.

`story.txt` is read one line per event with `fscanf` (O7:18FF): lines of more than 3 characters
are text; lines of 1..3 characters are picture markers (8 markers, 44 text lines, then Ctrl-Z
which text mode treats as end of file: **DOS file**; Ctrl-Z rule PC knowledge). The waits of one
event, in order:

| Step | Address | Primitive and argument | Duration (frames; clocks = frames·`P`) | s @70 / @60 | Skip | Label |
|---|---|---|---|---|---|---|
| Not due | O7:18B0 | compare now with due | 0 | – | – | DOS listing |
| Dim the previous line | O7:18D2..18F0 | redraw in colour 3, `wait(5)`; only while DGROUP:6802 < 40 and state ≠ 2 | 5 | 0.071 / 0.083 | no | DOS listing |
| Read the line | O7:18F3 | `fscanf`; end of file → "End" below | – | – | – | DOS listing |
| Skip test | O7:1912 | `kbhit` and DGROUP:67FC = 1 → "End" without its wait | – | – | key, only after world generation, and only when an event is due | DOS listing |
| Clear the strip | O7:1925 | copy from page 2 (after the first picture) | untimed | – | – | DOS listing |
| Pause | O7:1952 | `wait(10)` | 10 | 0.143 / 0.167 | no | DOS listing |
| Text in | O7:195E..1991 | draw in colour 3, `wait(5)`, draw in colour 11 | 5 | 0.071 / 0.083 | no | DOS listing |
| Text line | O7:19A6..19D8 | first text line: start tune 4 (above); `w` = 2 (+1 if > 19 characters, O7:1B35); DGROUP:6802 + 1 | – | – | – | DOS listing |
| Picture: cycles off | O7:19F5..1A17 | VGA: stop slots 1..DGROUP:3B68 | – | – | – | DOS listing |
| Picture: load | O7:1A19 | `birth<n>.pic` into page 2 (n = 1..8 from DGROUP:3B64) | untimed (disk) | – | – | DOS listing |
| Picture: fade out | O7:1A39 | VGA: `R:0000:04D4(8, 0, 0, 0)` | 48 | 0.685 / 0.800 | no | DOS listing |
| Picture: show | O7:1A41 | copy page 2 to the screen | untimed | – | – | DOS listing |
| Picture: fade in | O7:1A6B..1A93 | VGA: `birth<n>.pal` into DGROUP:C5BE, `R:0000:04AA(8, C5BE)` | 48 | 0.685 / 0.800 | no | DOS listing |
| Picture: cycles on | O7:1A9B..1B27 | VGA: for each byte triple (lo, hi, speed) of this picture's group in R:2710:0000..0082 (zero-terminated groups, **DOS file**): slot `i`, `rate` = floor(300/speed) stored as a byte (speed 1 gives 300, stored as 44), started with +`i` | `rate` frames per step (about `speed` steps per 300 frames, 4.28 s @70) | – | – | DOS listing |
| End | O7:1B6A..1BB8 | at end of file only: `wait(180)` (B4h); then close, `S#1(1)`, stop the slots, state 2, return 0 | 180 | 2.568 / 3.000 | no | DOS listing |

So a text event takes 20 frames of waits (15 when the dim step is skipped) and a picture event
20 + 96 frames (VGA). Text appears about 15 frames after its due tick. A picture marker uses the
due tick of the event that follows the preceding text line; the text after a picture is due at
once (`w` = 0). Before tune 4 starts the first two events run back to back (due 0).

After the story (state ≥ 2) each call returns 0 at once. The next three calls advance the state
from 2 to 5 (O7:17F4); the third, which reaches state 5, clears a rectangle (O7:17FF..1816,
FillRect through R:0000:0BFA); from then on "BUILDING NEW WORLD..." is
redrawn on each call in colour 15 or 3 by the parity of (frame counter / 60): it alternates every
60 frames (0.856 s @70) counted from the last `wait` (O7:17ED..1847, **DOS listing**). This is
seen only when world generation outlasts the story. If a key is pending in a state ≥ 2, the call
takes the event path instead: it returns 1 until the tick counter (restarted by the final
`S#1(1)`) passes the last due tick, then reads the closed stream (end of file, **inferred**) and
waits 180 frames (**DOS listing**; how often this happens is **unknown**).

### 5.6 Palette cycling set-ups

All set-ups found (R:0000:0382 call sites; **DOS listing**). Step time = `rate` frames.

| Where | Slot: DAC range, `rate` | Started / stopped | Step @70 / @60 |
|---|---|---|---|
| Intro O2:02F4 | 1: 146..152, 14 | started O2:030B (VGA, slots 1..3); stopped O2:0B40 | 0.200 / 0.233 s |
| Intro logo O2:0AA0 | 4: 224..239, 14 | started O2:0AAC (VGA); stopped O2:0B40 | 0.200 / 0.233 s |
| Birth O7:1AF0 | 1..8 from the R:2710 groups, floor(300/speed) | O7:1B16; stopped O7:1A06, O7:1BA5 | per entry |
| Map R:1DC4:05DD (after setup, R:01A8:086F) | 1: 96..103, 15; 2: 104..111, 15; 3: 112..127, 15 | R:1DC4:0626 / R:1DC4:065F | 0.214 / 0.250 s |
| Space sequence O2:12B1..1329 | 1: 16..31, 15; 2: 32..34, 100; 3: 35..40, 42; 4: 41..47, 300 (stored as 44); 5: 48..53, 60; 6: 54..63, 37 | O2:133B; stopped O2:148A | 0.214 s .. 1.427 s @70 |
| O18:00E0..0140 | 1: 208..223, 30; 2: 192..207, 11; 3: 224..239, 20; 4: 144..159, 8; 5: 128..129, 150 | O18:0157; stopped O18:0192 | out of scope |
| O19:0ED8 | 4: 64..79, 15 | O19:0EE4; stopped O19:0F94, O19:0FE6 | out of scope |

### 5.7 Other O2 sequences (end of game, out of the requested scope)

`O2:0BD7` (planet1/2.pic, spacest.pic, king.txt "*SPACE"/"*SPACE2") and `O2:152A` (arch.pic,
king.txt "*ARCH") are called from the game loop `R:0238:0092`, not from the start-up. Their
purpose is not established here (**unknown**). Since unit D7l2 (2026-10-17, DOS listing; `../ext-D7l2-record.md`)
`O2:0BD7` is known to be the spaceship arrival (the counterpart of ShowSpaceshipArrival 11D8:0000, PROF row 130), its
waits as listed below; the port draws it at the core's pace (TC: the pan's 320 columns over the core's 153 steps of 12
ticks, a chunk of the rest per 40 steps of 5 ticks; the record's deviation 1, FIDELITY F260); `O2:152A` stays
unknown. Their waits (**DOS listing**):

| Address | Primitive and argument | Duration | Skip |
|---|---|---|---|
| O2:10D7, O2:10A9..10C8 | per pan column: frame counter cleared at the top; catch-up skip of an odd column if > 12 frames; then wait until ≥ 8 frames | 8 frames per column, 320 columns: 2,560 frames (36.53 s @70); a text chunk every 22 columns (176 frames) | no |
| O2:122B | VGA: fade to black, 5 steps | 30 frames | no |
| O2:1434, O2:1457 | `wait(80)` twice per text chunk, after `R:0000:104F` at (118h, 20h) with colour 15 and then 0 | 160 frames per chunk (2.28 s @70) | no |
| O2:175A | `wait(200)` per chunk unless the chunk ends with "!" or `kbhit` | 200 frames (2.85 s @70) | key |
| O2:1798 | `wait(300)` after starting a tune taken from a table at DGROUP:1518 | 300 frames (4.28 s @70) | no |

### 5.8 Other timed sites (outside the requested scope; for reference)

`wait(n)` call sites (**DOS listing**; frames): R:01A8:0218 (1, in a function found only by the
prologue scan), R:0403:03DD, 1F8B, 3215 (30), R:0403:323A (10), R:0866:0C12, 0CD0 (10), R:0866:1F16
(1), R:0D12:4A43, 5094, 50BD, 5264, 52A0, 5455, 5499 (10), R:19F3:062A (2), R:19F3:06F2 (4),
O6:1D22 (10), O9:03A3 (30), O9:14E9 (60), O12:0CA5 (60), O18:0B18 (4), O19:0F3D (60), O22:0959
(30), O22:0A92 (5), O23:04E2, O23:0518 (10).

Fades (frames = 6 × steps): R:0238:1B66 to black (30), R:0238:1C86 to DGROUP:C5BE (30),
R:0ADE:198C (180), O9:1079 (30), O9:124C (48), O17:0CB9 (30), O19:0EB9 (90), O22:10FC (60).

Frame-paced loops with the counter read directly: O9:129E..1367 (until 240 frames), O19:17E9..1888,
O19:19FB..1AAD, O19:1BB5..1C6F, O22:101A..10B2 (10 frames per animation step, then `kbhit`).

## 6. Open

1. **No observation.** Every duration here is derived from the listing. A DOS-oracle run would
   confirm the calibration result on the emulated VGA (`P`, `k`), the 6-of-7 sound tick, the
   intro's absolute times and the dissolve's real length.
2. **Display rate for the port.** The DOS program measures the refresh at run time. The VGA
   value 70.086 Hz is PC knowledge; the port must choose a rate (frame clock 70.086 Hz and sound
   tick 6/7 of it, or the 60 Hz fallback). A port decision, not a DOS fact.
3. **Sound drivers other than NSOUND.** The meaning of the `S#3` return values (fast-mode
   requests) and the conditions under which ASOUND and RSOUND stop their tick counter are
   unknown; with a stopped counter the intro's waits (O2:04A0, O2:0A19) and the menu's phrase
   wait (R:01A8:04C2) have no exit. Tune lengths, looping and the meaning of tune 1 are unknown
   (sound out of scope).
4. **Dissolve duration.** `G#10`'s length depends on its calibration, the interval it measures
   (frame minus the vertical retrace pulse, PC knowledge) and the interrupt load during the copy.
   About 2.07 s for the intro on VGA is an estimate. The scaling path for a negative shift count
   (G:0000:072B) gives a delay of 1 for extreme values (**inferred**).
5. **EGRAPHIC and TGRAPHIC.** Only the head of their `G#10` was decoded (same scheme, different
   constants). Their palette, retrace and per-frame (`G#51`) functions are not analysed; the
   callers skip fades and cycling when DGROUP:D762 is 0 (not the MCGA/VGA driver).
6. **Phase of the interrupt within the frame.** That IRQ0 falls at the start of vertical retrace
   follows from the resync design (**inferred**); not measured.
7. **BIOS clock credit at install** (2× the elapsed time, section 2.2) and the hang risk of the
   in-interrupt retrace wait (section 2.4) are inferred from the code, not observed.
8. **Birth after the story with a pending key** (section 5.5, last paragraph): the path is in
   the listing; how often it happens and how long it stalls were not traced.
9. **Fade edge cases** (divide error with 1 or 2 passes, no visible fade with 0 passes, `E` = 0):
   inferred, not reachable on normal VGA hardware.
10. **`G#29`** (SetShakeCount, the only writer of the shake count) has no callers in the
    listings; whether an unresolved indirect call reaches it is unknown.
11. **Phase of the 6-of-7 divider.** DGROUP:005E counts frames from the timer install and is not
    reset by `S#1`, so on VGA the PIT tick of the n-th sound tick after a tune start is one of two
    values (units section); which one depends on the frames elapsed since the install (disk and
    set-up times). The port must choose one (a port decision, not a DOS fact).

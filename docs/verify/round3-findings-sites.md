# Round 3 (2026-10-09): review of the findings-site generator change (W4)

Scope: `claude/port/build/verify-round3/diff/gen-findings_sites.diff` (old copy
`verify-round3/gen-old/findings_sites.py`, current `claude/port/gen/findings_sites.py`) and the
STATEMENT lookup in `verify-round3/diff/gen-translate.diff` (`translate.py` lines 1531-1546).

Method labels:

* **[L]** listing, `showfunc.py` (function or address range);
* **[G]** generated C in `claude/port/core` (unit file and line);
* **[F]** `claude/docs/findings.md` (line numbers of the current file) and the earlier verifier reports
  named in the generator's reasons;
* **[T]** generator source read (`findings_sites.py`, `translate.py` 1503-1546 and
  `governing_marker` 1884-1890);
* **[R]** the generator's own site list: `C:/Python314/python -B claude/port/gen/findings_sites.py`
  (no arguments; read-only, prints the site list; output kept in my scratchpad as `w4_sites_all.txt`);
* **[C]** computed: awk/grep over findings.md sections 4-10 (lines 113-1571 without 8.2, lines
  1340-1377, exactly the text `_entries` parses), the site list and the core function headers.

Nothing was built, compiled, tested or run; nothing under `claude/port/gen` other than the printing
run above was executed.

## 1. EXCLUDE (12 entries)

| finding, address | findings.md text [F] | listing [L] | verdict |
|---|---|---|---|
| C1 1098:095C | line 610: "`g_messageTimerId` (12D8:460E, set by `InitApplication` at 1098:095C) is overwritten" | `mov es:[g_messageTimerId],ax` after SetTimer: the victim's own in-range store | context: correct |
| C20 1098:1260 | line 821: "The cursor is not left busy: `GR_DialogOpen` sets cursor 0x81 on entry (1098:1260)" | `push 0x81` for SetGameCursor | context: correct; reason wording, see N2 |
| H35 1008:0177 | line 1236, harmlessness column: "`WinMain` runs the conversion (call at 1008:0177) before any other GR dialog" | `call far ConvertArtworkFor16ColorDisplay` | context: correct |
| L12 10B8:07FF | line 1459: "The cache-miss path at least reports the failure (10B8:07FF..0825, L9)" | 07FF `push 0x42` of the cache-miss GlobalAlloc, failure reported at 081D | context for L12: correct. The (L9, 07FF) site is keyed separately and stays [R] |
| G62 1028:144C | line 527: "`BuildLandZoneLinks` resets its counterpart at 1028:144C" | `mov word [bp+dstBodyId],0xffff`, the correct reset | context: correct |
| H60 11A8:1088 | line 1261, harmlessness column: "`DrawTileImpl` (call at 11A8:1088, non-palette devices) copies every drawn tile" | `push cs; call CopyTile` | context: correct; H60's sites 11A8:025F and 0383 stay [R] |
| L14 11A8:090C, 091A, 091F | line 1483: the exits "jump to 11A8:091F, past the unlocks at 11A8:090C/091A" | 090C and 091A are the two `GlobalUnlock` calls; 091F `pop di` is the epilogue target of 0784/078D/0845/088A/0915 | context: correct; OverlayTile keeps 0793/07A1 (locks) and 0843/088A (exits) [R] |
| L14 1208:1CE3, 1D18 | lines 1487-1489: "test at 1208:19DD, jump at 1208:19F3 to 1208:1D18 ... the common exit 1208:1CE3..1D13 is skipped" | 1CE3 starts the skipped exit (ForgetGrPort push); 1D18 `pop di` is the epilogue the jump reaches | context: correct; 19DD and 19F3 stay [R] |
| L14 1118:0000 | line 1484: "`RenderTileFromKey (1118:0000)` uses it for every full-size overlay (V4)" | entry of RenderTileFromKey; the leak is in OverlayTile | context (a user, not a site): correct |

Mechanism [T]: an excluded address is skipped before `site_of` (line 219), and an excluded function
entry is neither a citation (line 204) nor an entry site (line 225). The citation position stays in
`cite_spans`, so the bare-address loop does not pick the excluded entry up again. All 12 addresses
are instruction starts [L], so the check on the textual address matches what `site_of` would map.
The brief says EXCLUDE "now holds 12 context addresses": 12 [C].

## 2. MANUAL (new entries)

The diff adds 10 entries, not 11 as the brief states [C] (U4 2, C14 1, C9 3, H61 4); one of them
(C9 2209) re-classifies an address the parser already reads.

| entry | listing [L] | finding [F] | kind | verdict |
|---|---|---|---|---|
| U4 1110:1822 | `push cs; call GetTileUnitCiv` with (x, y); the callee reads byte (x+0xA0, y) at 18DC..18E3 | U4 line 1317: "`FindUnitAtTile` with x = -1/80 reads column 159/240" | OOB (U) | real site, correct |
| U4 1110:18BD | `call far SetScreenBufferPixel(x+0xA0, y, 0)` (18B1..18BD) | same sentence: "its stale-marker repair may overwrite the square-claim byte" | OOB | real site, correct |
| C14 OOB 11A8:155C | `mov es:[di],al`, the only store of the scaled DDA path (1520..15C4) | C14 line 760: one extra column/row written past the `n*num/den` buffer | OOB | real site, correct (the access) |
| C9 OOB 1068:2232 | `mov es:[bx+0x9a],dx`, lineOffset[DI] (64 words, +0x9A..0x119) | C9 line 690: `lineIndex` "runs past the 64-entry line tables and the 0x51A-byte block" | OOB | real site, correct |
| C9 OOB 1068:224F | `mov es:[bx+0x1a],ax`, lineLength[DI] (+0x1A..0x99) | same | OOB | real site, correct |
| C9 BUG 1068:2209 | `or si,si; jg`, the `wordCount <= 0` test | C9 line 689: the fallback "is only reached when the line is not full" | BUG | real site; BUG is right under 5.2 item 3 (not an access). It overrides the parsed OOB kind (N1) |
| H61 10B0:15E9 | `mov es:[bx+0x3dc],si`, order[si] = si for si < duration | H61 line 1262: "fills its 480-word `order[]`/`rowPhase[]` for indices 0..duration-1 ... without a bound" | BUG (H) | real site, correct |
| H61 10B0:160C | `mov es:[bx+0x1c],dx`, rowPhase[row] | same | BUG | real site, correct |
| H61 10B0:1665, 1674 | the swap writes order[swapA], order[swapB] (indices < duration) | same (unbounded order[] use) | BUG | real sites, correct |

All kinds follow the docstring rule (U → OOB; C with an OOB keyword → OOB; H → BUG), except the
deliberate per-site override at C9 2209 (N1).

## 3. STATEMENT (2 entries) and the lookup in translate.py

[L] CreateDissolveState places the rowPhase loop body at 15F7..160C (Random, `and`, `cwd`, 1600
`idiv di`, 160C store) and its test at 1610..1618; 15F5 jumps to the test. [G]
`seg023_10B0_p1.c` has markers 15D3 (order loop, l.1515) and 1610 (rowPhase loop, l.1527) and no
marker between them, so `governing_marker` of 1600/160C would be 15D3, the order-fill statement
that already names H61 (no comment would appear, as round 2 reported). With STATEMENT both map to
1610, the statement whose `for (;;)` holds the Random call, the `IMOD16` (idiv 1600) and the store
(l.1529-1537): one comment `/* BUG: findings H61 */  /* 10B0:1600 */` at l.1528 (160C is merged by
the one-comment-per-statement rule). Both entries are correct.

[T] `translate.py` 1534-1535 now evaluates `gm = FS.STATEMENT.get((fid, a)) or
self.governing_marker(a)` per finding inside the site loop, so the redirect applies only to the
named finding at that address; other findings at the same address keep the governing marker. A
STATEMENT target that is not a marker of the function would stay in `comment_at` and be reported by
the existing "site comment at marker ... not emitted" finding (l.1575-1576); `load` checks that site
and target lie in one function (l.193-195). No defect.

## 4. `SSSS:OOOO/OOOO` parsing

[T] `MORE_RE = /([0-9A-F]{4})\b` is matched only at the position right after an `ADDR_RE` match
that is not a citation; each further `/OOOO` becomes an address in the first match's segment.

[C] Sections 4-10 contain 57 slash lists with 62 continuation addresses. Every one is an address
list of the same segment:

* code lists (for example 1098:0246/024A, 1208:1DFD/1E21, 1128:15B4/1615, 1030:4AF0/4B04/4B4C,
  1170:0FCD/0FE7/0FEF, 10B0:1600/162A/1638);
* one data list, 1420:6300/6301 (line 128), which `site_of` ignores (no function in 1420);
* lists that end in a range, 1190:180B/1934..193B, 1190:18AA/190E..1919 and 1078:3329/333D..3364:
  `MORE_RE` stops at `..`, so only the range start is read, as for every other range;
* the arrow form 1018:1677/167D -> 1018:1687: the arrow is not parsed and the target is a separate
  `ADDR_RE` match (a real V26 site, the `idiv` 1687).

No continuation is followed by `:`, so no segment number is misread as an offset. The only
`Name (SSSS:OOOO/OOOO)` form, `` `PreconvertPicture` (10B8:0777/0789) `` (line 791), is not a
citation (`CITE_RE` needs `)` after the first address, and 0777 is not the entry 10B8:076A), so
both addresses are sites, as intended (0789 is also MANUAL C18). **No misread.**

[R][C] 60 of the 62 continuation addresses become sites; the other two are 1420:6301 (data) and
11A8:091A (EXCLUDE). 13 of the 60 lie in ported functions, and each is a real site [L]: 1028:105B
(G69 `jge`), 1028:11B0 (G63 `or si,si` entry-0 test), 1098:024A (V1 `jbe`), 10B0:07BB (V7 count
argument), 10B0:162A/1638 (H61 `idiv`), 10B8:0789 (C18, also MANUAL), 1110:069C (U4 `imul` of the
unwrapped index), 1128:1615 (H16), 1128:16FE (H14), 1208:1E21 (V23), 1220:0366 (C10 strcpy) and
1220:149D (V20 '2' loop).

Not misreads, but not read either (segment-less continuations after a comma): for example
"1128:140E, 1277/13E3/1577" (H15), "11A0:07BC/097C, 07DF", "1078:3329/..., 351E/3562",
"11C0:3B0F, 3B22/3B4D". Of these, only H15's 1128:1277/13E3/1577 lie in ported code, and
`gen/annot.py` `"1128:10DE"` comments cover them [G] (`seg038_1128.c` l.109, 197, 265).

## Findings

No TRANSLATOR finding: every new EXCLUDE, MANUAL and STATEMENT entry is correct, and the parser
misreads no text of sections 4-10.

* **N1 NOTE (docstring).** The classification paragraph of the docstring states only the
  per-finding rule; MANUAL's per-site kind (`"BUG"` for C9 1068:2209 against C9's OOB class, like
  the older C16 entries) is documented only in the comment above MANUAL. The override itself agrees
  with 5.2 item 3 (OOB only for an access).
* **N2 NOTE (reason text).** The C20 1098:1260 reason says "GR_DialogOpen is not a C20 site". The
  function keeps its C20 site 1098:12D2 (failure return 12D2..12E3; `seg020_1098_p1.c` l.455),
  correctly; only the cursor call is context. Suggested wording: "the cursor call that rules out
  the busy-cursor claim".
* **N3 NOTE (consistency of EXCLUDE; no effect in the current core).** Addresses of the same roles
  as the new exclusions are still sites:
  * L14 ScrollMapVertical 1208:08C2 (the skipped `GlobalUnlock`) and 1208:08C7 (the epilogue the
    jump 076C reaches), like OverlayTile 090C/091A/091F and DrawTilesToPort 1CE3/1D18 [L];
  * L14 Superimpose's caller call 1030:56F7 ("its only caller is the city-screen composition (call
    at 1030:56F7)"), like H35's 1008:0177 and H60's 11A8:1088.

  None of these functions is ported. Function-level citations that name a function as a user or a
  source of a value, like RenderTileFromKey for L14, still produce `function cited` comments in
  ported units: U3 `FindUnitAtTile (1110:180E)` (`seg035_1110_p1.c` l.51), R3 `HasHut (1110:1CD9)`
  (`seg035_1110_p2_s.c` l.57) and H63 `GR_DialogClose (1098:1612)` (`seg020_1098_p1.c` l.721).
  They follow the rule; the last two were already round-2 NOTEs.
* **N4 NOTE (H61 class).** The H61 fill and swap sites are out-of-range stores when duration or
  height exceeds 480, but H61 is an H finding, so the rule gives BUG. This is consistent with the
  docstring; 5.2 item 3 would suggest OOB if such a script existed (none does: H61's harmlessness
  column, findings D4).
* **N5 NOTE (allowlist, open per the brief).** The verifier-located out-of-range sites 1068:2232,
  1068:224F (C9), 11A8:155C (C14), 1110:1822 and 1110:18BD (U4) are not in the corresponding rows
  of `inventory/out-of-range.md` (C9 lists 2072/2118/2209/2302, C14 13C0, U4 has no 1110:18xx).
* **N6 NOTE (newly read consequence site, unported).** The slash parse now also reads H12's
  11C0:1185, a reader of the stale `g_statusWindowPort.rect` (BlinkActiveUnitUntilInput), next to
  11C0:1054, which was already a site. These are consequence sites like C1's 1008:0391; not ported.

| item | verdict | TRANSLATOR | RECOVERY | NOTE |
|---|---|---|---|---|
| EXCLUDE (12) | correct | 0 | 0 | 2 (N2, N3) |
| MANUAL (10 new) | correct | 0 | 0 | 2 (N1, N4) |
| STATEMENT (2) and the translate.py lookup | correct | 0 | 0 | 0 |
| `/OOOO` parsing | no misread | 0 | 0 | 1 (N6) |
| allowlist | open per the brief | 0 | 0 | 1 (N5) |

Not checked: the generated comments of units other than mine, beyond the placements quoted above
(their verifiers check them); runtime behaviour.

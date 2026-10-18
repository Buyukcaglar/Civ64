# Phase 0 acceptance record

Phase 0 (prompt section 9): hash the originals, read the inputs, generate the inventories.
Gate: `DESIGN.md` draft with all inventories.

| Item | Method | Result |
|---|---|---|
| Original hash check (session start) | inline PowerShell of prompt section 10 | PASS, 38 files — `hashes/20261008T115412Z-before.txt` |
| Inputs read | reading | `claude/docs/README.md`, `claude/src/README.md`, headers, findings sections 1–3, 8, 12, architecture 2.3–3.6, db schemas, listing format; the rest is read per phase as needed |
| Front end over all inputs | `gen/check_parse.py` (headless, Python) | 89/89 C files and civ.h parse; 1,070 definitions, 808 globals, 1,221 prototypes |
| Struct layouts | `gen/layout.py` | 78 structs; all 496 documented member offsets and 61 documented sizes agree (two "N + variable data" headers accepted) |
| Global addresses | `gen/layout.py` vs names.json | 806/806 agree |
| Inventories | `gen/inventory.py` | 12 files in `inventory/`; liveness equals findings D1 (211 dead) |
| `DESIGN.md` draft | writing | present, with all inventories linked |

What was compiled: nothing (phase 0 needs no build). Tested headless: only the Python
generators above (they are tools, not port tests). Agent-observed, oracle-compared,
user-confirmed: nothing. Unverified: every design decision of `DESIGN.md` is a draft until the
phase-1 design review.

**Gate: met.** Continue with phase 1 in the same session (section 11).

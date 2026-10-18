# Extension phase D1 — acceptance record

Prompt: `claude/docs/x64-port-scaling-dos-prompt.md`, phase D1 (section 9): "Design of the observer and
presentation tick, composition and shadow surfaces, classes, timelines, adapters, the map renderer, the
palette rule and text; the "Extension" section of `DESIGN.md`." Gate: "Independent design review
recorded with resolutions." 2026-10-11: five design agents (areas A..E, Revisions 1 and 2), two
read-only reviewers (RV1, RV2), the orchestrator's resolutions, and the integrator (Revision 3, the
D0 corrections, DESIGN.md 12.5..12.11, FIDELITY, the checklist, this record). Briefs:
[verify/BRIEF-d1.md](verify/BRIEF-d1.md), [verify/BRIEF-d1-review.md](verify/BRIEF-d1-review.md);
resolutions: [verify/ext-d1-decisions.md](verify/ext-d1-decisions.md).

D1 is design only: nothing is implemented, built or run. DOS facts carry the D0 labels (DOS file, DOS
listing, inferred, unknown); no DOS-oracle run was made.

## Gate

| Item | Method | Result |
|---|---|---|
| Area A: observer, probes, queries, tick, profiles, switching, input stages, P0 tests (5.1, 5.2 O1..O7, 5.6 I2 I7, 5.11, 7.3, 7.4, 7.8, G-1) | [verify/ext-d1-draft-A.md](verify/ext-d1-draft-A.md) Revision 3; summary DESIGN.md 12.5 | designed; reviewed (RV1, RV2); resolutions applied (Revisions 2, 3); 203 probe keys, every exit another area uses present (RV2-1) |
| Area B: composition, N and A canvases, shadow surfaces and the macro engine, replay, palette, fonts, re-skins, the DOS small map, status window and unit panel (5.3, 5.4, 5.7, 5.10) | [verify/ext-d1-draft-B.md](verify/ext-d1-draft-B.md) Revision 3; DESIGN.md 12.7 | designed; reviewed (RV2: 34 claims checked with C); resolutions applied (Revision 3) |
| Area C: DOS clock, timelines, scene sequencing, adapters, I4, I5 (5.5 T1..T7, 5.6 I1 I3..I6 I8, 7.7, 7.8) | [verify/ext-d1-draft-C.md](verify/ext-d1-draft-C.md) Revision 3; DESIGN.md 12.8 | designed; reviewed (RV2); resolutions applied (Revision 3) |
| Area D: map renderer and zoom (5.8, Z-1, Z-2, 7.5), the DOS map | [verify/ext-d1-draft-D.md](verify/ext-d1-draft-D.md) Revision 3; DESIGN.md 12.9 | designed; reviewed (RV1, RV2 interfaces); resolutions applied (Revisions 2, 3) |
| Area E: DOS assets at run time (5.9, 7.6, phase R hand-off) | [verify/ext-d1-draft-E.md](verify/ext-d1-draft-E.md) Revision 3; DESIGN.md 12.6 | designed; reviewed (RV1, RV2 interfaces); resolutions applied (Revision 2; Revision 3 wording only, interfaces unchanged) |
| The "Extension" section of DESIGN.md | DESIGN.md 12.5..12.9 (one per area, 65..88 lines, each linking its draft), 12.10 "w16 changes" (K2), 12.11 "Scope of P0" (K1) | written |
| Conflicts between the drafts and with the prompt | [verify/ext-d1-decisions.md](verify/ext-d1-decisions.md): K1..K9, C1..C7, E.18-1..5, X1..X6, C.20-1..10, C-11, C.20.2-2, RV1-1..20, RV2-1..18 | every one resolved; applied in the drafts' Revision 2 or 3 lists |
| Independent review | two read-only reviewers who wrote none of the drafts; index [verify/ext-d1-review.md](verify/ext-d1-review.md) | recorded: RV1 1 blocker, 6 major, 9 minor, 4 notes; RV2 1 blocker, 2 major, 11 minor, 4 notes; every finding resolved, none rejected |
| Blockers and majors applied in the drafts | integrator's check of each against the drafts and its evidence (the review index's table) | all 10 applied: RV1-1..RV1-7 (Revision 2), RV2-1..RV2-3 (Revision 3); RV2-1 checked against WINDOWS-INVENTORY.md 10.6 and 10.7, RV2-2's `ra` values against the call instructions |
| D0 corrections named by D1 | OPEN.md P15 (C.20-1) and P22 (C.20-5); DOS-PROFILE.md row 9 and 3.1 (C.20-3), 1.7 (C.20-4); TIMING.md 5.3 (C.20-6) | applied, each with a correction note; P15's stores checked by `showfunc.py` 1108:0000, TIMING 5.3 against O2:0A0F..0A16 → O2:0B26 |
| OPEN.md P items (D0 hand-off to D1) | [dos/OPEN.md](dos/OPEN.md): each row ends with "Settled in D1: draft, section" | 29 of 29 settled; later parts named for P10 (a DOS-oracle observation at D4 may revise it), P14 (OB4 at D6/D7), P27 (the scenes at D4/D7; O7 stays open) |
| Recorded design choices | [FIDELITY.md](FIDELITY.md) "Extension D1: recorded design choices (implemented in later phases)" | F113..F138 (26 entries), each "designed in D1; implemented in <phase>" |
| The user's checks | [manual-checklist-ext.md](manual-checklist-ext.md) | 12 items, all pending: D3 5, D4 3, D5 1, D6 1, M 2 |

**Gate met** (2026-10-11): the design exists for every item of the D1 row and the "Extension" section
of DESIGN.md is written; the independent review is recorded with resolutions, and every RV1 and RV2
blocker and major is resolved in the drafts (RV1-1..RV1-7 in Revision 2, RV2-1..RV2-3 in Revision 3).

## Reviews and resolutions

| Review | Scope | Counts | Resolution |
|---|---|---|---|
| RV1 ([verify/ext-d1-review-rv1.md](verify/ext-d1-review-rv1.md)) | A, D, E at Revision 1 | 1 / 6 / 9 / 4 | "Design review RV1" of the decisions: RV1-1 E owns `pdos_shapes` (the O5:1455 cut); RV1-2 `pmap_layer_point`; RV1-3 `present/map/pmap_*.c` in the build; RV1-4 D's A-1..A-8 adopted, K2 extended; RV1-5 `--dos-data` and switch assertions; RV1-6 Locate effective at the next start; RV1-7 the cursor route; minors and notes applied; RV1-17 handed to RV2 |
| RV2 ([verify/ext-d1-review-rv2.md](verify/ext-d1-review-rv2.md)) | B, C at Revision 2; every interface between any two of A..E | 1 / 2 / 11 / 4 | "Design review RV2": RV2-1 exit phases on nine functions with a lint and the macro check; RV2-2 two `OBS_CALLSITES` rows; RV2-3 the press latch; RV2-4..18 applied as proposed (RV2-12 by its first option, Choice B24) |

The merge items C-11 (the filter routes a later part of a C-decided action to C) and X5 (D's label
font L17 → L23) are applied. Area E's interfaces are unchanged by Revision 3.

## OPEN P items settled

All 29 P items of [dos/OPEN.md](dos/OPEN.md) are settled in D1, each row naming its draft section:
area C alone P1, P2, P7, P10, P15, P22, P25, P26, P29; area B alone P4, P5, P11, P12, P13, P14, P18,
P19, P20, P23, P27; B with C's input P16, P17, P21, P24; B, C and D P3; C and D P6; D drawn by B P9;
area E P8, P28. Three
carry later parts: P10 (DOS-oracle observation at D4), P14 (font in effect during play, OB4 at D6/D7),
P27 (the scenes that draw the odd-width rows at D4/D7; O7 stays open). The L group (listing work) and
the O group (DOS-oracle observations) stay open with their phases.

## Carried forward

* Open items of the drafts, each with its phase: A1..A7 and A9 (A 16; A8, A10, A11 closed); OB1..OB11
  (B 19; OB8 partly resolved); C-2..C-9 (C.19; C-1, C-10, C-11 closed); D1..D8 (D 21; D9, D10 closed);
  E1..E8 (E.17).
* Whether ScaleLogicalX/Y keeps its exit probe: decided at D3 (A 17, RV2-15; B does not need it).
* Asan deferred (K8): gate records say "Asan deferred"; one Asan pass at the end of the queue,
  including `test_dos`.
* The 12 user checks of [manual-checklist-ext.md](manual-checklist-ext.md), pending until the phase
  that makes each possible.
* FIDELITY F113..F138 describe designed behaviour; each phase that implements one confirms or corrects
  its entry.
* The drafts remain the detailed design; later phases correct them where implementation or an
  observation shows more, with a note in the draft and in DESIGN.md 12.

## Not verified

* Nothing of D1 is implemented, compiled or tested; no harness, P0 or frame-equality run exists yet
  (D3 onwards).
* No DOS behaviour was observed (no DOS-oracle run): timelines, fades and the clock model are "DOS
  listing (model)" until 7.9; C.15.3's goldens will be model fixtures (C-9).
* The integrator re-checked the evidence of the blockers and majors and of the D0 corrections, not
  every claim of the drafts; the reviewers' samples (RV1, RV2: 34 claims for B and C) stand for the
  rest.
* No DOS-file hash check was run in D1 (no DOS file was read or written by the integrator).

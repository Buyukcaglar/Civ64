# Unit D6fSd: the DOS game's own texts and places for the remaining boxes (follow-up of D6fSc)

Orchestrator brief, session E4, 2026-10-17 about 22:35 UTC. A follow-up of rework unit D6fSc
(`verify/BRIEF-d6fsc.md`, `ext-D6fSc-record.md`). It is queued as a rework: it lands after D7e and before the later
D7 units if READY first.

## Why

The user's report of 2026-10-17 about 18:28 UTC ("QUIT to DOS popup dialog is also wide then it should be.") and the
standing direction that the DOS graphics show the DOS game's own menus and boxes (revision list of about 07:00 UTC,
item 5: "DOS graphics shall exactly reflect DOS game menu and its contents"). D6fSc gave five boxes the DOS game's own
text. Two gaps remain, both recorded in its record under "Deviations and limits" and "DOS place":

1. **The KING.TXT boxes.** The advisors' notes, disasters, celebrations and other KING texts, about 60 sections, keep
   the core's Windows words and capitals with only DOS-like breaks. The core's LoadKingText 11D0:01F7 (TEXT
   `KNG_name`) has no observer probe, so a box cannot tell which section it shows.
2. **The boxes' places.** Choice B16 anchors an A box at its Windows dialog's top-left. The core passes DOS's own
   x, y to ShowTextDialog 1220:00D2, which ignores them: (64, 80) for the revolution question and (100, 80) for tax,
   luxuries and Retire. The quit command 115 passes (0, 0), and its pairing would give DOS's (100, 80). In the user's
   DOSBox screenshot the quit box stands at about (100, 80).

## The unit (ruling under the user's direction)

* **KING pairing.**
  * Add a read-only observer probe at LoadKingText's entry or exit so the presentation knows the section name. Use
    the usual mechanism: the DOS-PROFILE call-site row, obs_tables, obs_lint and P0. The probe changes no core
    behaviour and draws no RNG.
  * A box showing a KING section draws the DOS game's KING.TXT section of the same name, read at run time from the
    user's DOS files through the store and a hash-pinned registry row, with no DOS byte in the repository.
  * It keeps DOS's line breaks, words and capitals, with R:1F4D:0471's tokens filled from the core's names and
    numbers.
  * Where the DOS file has no section of that name, or its tokens cannot be filled from the core, the box keeps
    D6fSc's fallback, recorded per section.
  * The same applies to ERROR.TXT and any other DOS text file the listing pairs with a core text source.
* **DOS places.**
  * In the DOS graphics, a box whose ShowTextDialog call carries DOS's x, y stands at DOS's place, mapped onto the A
    canvas as the DOS screen's coordinates are (the map area's origin, 2x, the existing clamp inside the canvas).
  * The quit question uses its pairing's (100, 80).
  * Boxes without DOS values keep B16.
  * This reverses Choice B16 for those boxes; record it with a FIDELITY F-new and the evidence.
* **Not in the unit.** The research choice and the other header boxes (D7g); the Civilopedia (D7h); the Windows
  graphics (unchanged).
* **Constraints (AGENT-RULES.md).**
  * P0: the core is unchanged, the presentation only reads, and there is no core RNG draw.
  * No new PDOS bits or owners without asking.
* **Tests.**
  * The probe's section names for a set of KING sections.
  * Paired texts against the DOS file, through registry hashes.
  * The fallback.
  * Places for the named boxes, including the clamp at the canvas edge.
  * ext_adapt pairs for two KING boxes and the quit and tax boxes' places.
  * The Windows graphics unchanged.
* **Record.** `ext-D6fSd-record.md`, with "What the user checks" items D6fSd-1.. naming concrete boxes and how to
  reach them (an advisor note at the start, a celebration, a disaster if a save reaches one), and a "For the
  records" section.

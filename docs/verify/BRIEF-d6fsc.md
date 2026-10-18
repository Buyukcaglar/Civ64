# Unit D6fSc: the DOS boxes' line breaks and widths (rework)

Orchestrator brief, session E4, 2026-10-17 about 18:30 UTC. A rework of units D5b, D6f and D6fS-a. It lands before the
later D7 units ("reworks first").

## The user's report (verbatim; STATUS "User directions", 2026-10-17 about 18:28 UTC)

> QUIT to DOS popup dialog is also wide then it should be. First uploaded screenshot from your latest build, second is
> from DOS game in DosBox.

The two screenshots (the user's; read only, never copied into the tree) are:

* `<scratch folder>`:
  civ64, user build "d6fsb". The quit question is one long line, "Are you sure you want to quit?", above "Keep
  playing" and "Yes, Quit". The box is about 360 DOS pixels wide.
* `...\images\6.png`: the DOS game in DOSBox. The box holds "Are you sure you / want to Quit?" on two lines, then
  "Keep Playing" and "Yes, Quit". It is about 104 DOS pixels wide and stands at about (100, 80).

The word "also" refers to the user's report of about 15:37 UTC on the science advisor's research choice. Its item
1 was "Dialog itself is too wide": DOS shows "Which discovery should our / wise men be pursuing, sire? / Pick one...",
while civ64 shows the Windows text's two long lines (BRIEF-d7.md, D7g).

## The cause (orchestrator's reading)

D6fS-a sizes every A box from its content (`ext-D6fS-a-record.md`, "The DOS sizes"): right = x + widest line + 8
(R:1D05:059D..05A7). The content is the core's (Windows) text, broken into lines as the Windows dialog breaks it.
DOS's strings are broken by hand ("Are you sure you" / "want to Quit?"), so DOS's widest line is much narrower.
The height rule is right; the line breaks are not.

## The unit

* **Scope.** Every re-skinned A box with text lines, in play and over N scenes:
  * the MenuZ boxes of dialogs 136 and 145 (DOS-PROFILE rows 14, 22);
  * the message boxes (`#MsgBox`, row 41);
  * the other rows of D6fS-a's list that carry text: 94, 141.
  The quit question (GAME > QUIT to DOS, Alt+Q, Ctrl+Q), the Retire and REVOLUTION! questions, the tax and luxuries
  boxes' titles, and the science advisor's research choice are the named cases.
* **The rule (ruling under the user's direction that the DOS graphics show the DOS game's own boxes).** A box's text
  lines are DOS's: DOS's line breaks, and DOS's wording and capitals.
  * Where the DOS game's own string for that box can be paired (by the listing: the DOS call site and its string in
    the DOS program or a DOS text file such as KING.TXT), the DOS string is read at run time from the user's DOS
    files through the existing provider and registry. No DOS bytes go into the repository or a binary; a hash-pinned
    registry entry is used, as D6fS-b's menu rows are. The core's dynamic parts (names, numbers, the advance list)
    fill DOS's slots.
  * Where no pairing exists, the core's text is wrapped by a rule fitted to DOS's boxes (the DOS listing's own wrap,
    if R:1D05 or its callers wrap; otherwise a stated width taken from DOS's strings), recorded per box class.
  * The box width then follows D6fS-a's rule, unchanged.
  * The rows' texts ("Keep Playing", "Yes, Quit") follow the same pairing.
  * A text difference (for example "quit?" against DOS's "Quit?") is part of the pairing, not a separate change.
* **Not in the unit.**
  * The box's place: Choice B16 anchors at the Windows dialog's top-left; F223's DOS-place anchor for the palace's
    KING box stays as it is. Report whether DOS's place (R:0238:001E's x, y) could be used in play, but do not
    change it.
  * The header variant (title, portrait, "(HELP AVAILABLE)") is unit D7g's. D7g reuses this unit's line rule for the
    research choice; name the shared function in the record.
* **Constraints (AGENT-RULES.md).**
  * P0: the core's behaviour is unchanged. The presentation only reads, and the core's strings and decisions are
    untouched.
  * No core RNG draw.
  * The Windows graphics are unchanged.
  * The pairing and wrapping are presentation-only.
* **Tests.**
  * Each named case's lines and width against the DOS listing's or DOS file's values (registry hashes, no DOS
    bytes).
  * The unpaired fallback.
  * The Windows graphics unchanged.
  * ext_adapt cases for the quit and revolution questions.
* **Record.** `ext-D6fSc-record.md`, with "What the user checks" items D6fSc-1.. that name the quit question, the
  Retire and REVOLUTION! questions and the tax box, and a "For the records" section.
* **Process.**
  * Stage in `build/d6fsc-stage` on the current tree, after HM and docs-e4e as they land; rebase at the slot.
  * Report READY with the counts.
  * The slot comes after HM and the docs pass e4e's marker, before the later D7 units.

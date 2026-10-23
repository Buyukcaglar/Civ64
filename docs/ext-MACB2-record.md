# Unit MACB2 (the graphics switch ended the intro on macOS) - record

## The user's words (2026-10-23, on the MAC4 build)

> switching back to Windows Graphics from DOS in intro causes the intro to be ended, switch graphics shortcut shall
> not be recognized as keypress, thus shall not end intro for that matter.

and, after a first look:

> the problem occurs when I let go shift and cmd (butterfly) on my keyboard, if I hold them down and press del
> repeadetly, it switches back and forth normally.

## Cause

The arrival stage (`present/arrive.c`, decision K3) holds a Shift, Ctrl or Alt press back until the next key shows
whether it belongs to a chord; a held key released alone is delivered with its press, as a lone key (it still skips
a movie, as on Windows). Shift+Command+Delete (MACB1's Mac equivalent of the switch) is a menu key equivalent: AppKit
gives it to the menu, so the arrival stage never saw the chord, and the Shift press it held was delivered at its
release. The game's intro ends on any key, and the DOS intro with it (seen: after the release the Windows logo, then
at the next switches the DOS and the Windows title menus), so the first switch worked and the release of Shift then
ended the intros. Holding Shift and Command while pressing
Delete again switched normally because the Shift release came only at the end. Control+Shift+Delete was not
affected (the arrival stage takes that chord itself).

MACB1's test of the shortcut used the test aid's `mods` step, which sets the flags of the posted key only and posts
no Shift press or release, so it did not reach this path. The reproduction here posts the Shift key's own events
(`fdown:56`, `fup:56`).

A second effect, not a defect, was seen while looking: the Windows intro is about 20 to 25 seconds long, the DOS
intro about a minute. Each graphics shows its own intro at its own moment (FEATURES "The graphics switch": "each
profile at its own moment"), so a switch to the Windows graphics after the Windows intro's end shows its title menu
while the DOS intro still runs. That is unchanged.

## Fix

* `present/input.h`, `present/arrive.c`: `pi_arrive_host_shortcut()`: the host took a key combination of its own
  that never reaches the stage; the modifier presses held back serve it, as a chord's (neither they nor their
  releases reach the game); keys already delivered are unchanged. Portable; only the macOS back end calls it.
* `platform/macos/host_macos.m`: the game view's `performKeyEquivalent:` calls it for every key pressed with
  Command (AppKit offers such a key to the view before the menu bar takes it). Every Command shortcut of the app menu
  (switch, zoom, full screen, Hide, Quit...) and a Command key with no item are covered.
* `tests/test_input.c`: `host_shortcut()`: a held Shift, and a held Ctrl and Shift released in either order, give
  nothing after the call; a later lone Shift is delivered again; a Shift delivered before the call keeps its release;
  with nothing held the call changes nothing.

## Tests (agent-observed on this Mac)

* `test_input` (Checked and Release): PASS, 704 checks.
* The Release app, `--graphics dos`, three switches in the intro at 3, 6 and 9 s with the Shift key's own press and
  release around Shift+Command+Delete: Windows intro ("Windows Version by"), DOS intro ("Designed by SID MEIER"),
  Windows intro again, each snapshot 2 s after its switch; before the fix the first release ended both intros (the
  Windows logo, then the DOS and Windows title menus). The same with Control+Shift+Delete (Control's and Shift's own
  events): unchanged, the intros continue.
* The full Checked suite (arm64): `TESTS_OK`, 31 sections, 0 failed, wall 1,040.8 s; G-1 `EXT_G1_OK runs 77` (its one
  recorded amendment, unchanged).

## User build

`build/user-builds/macb2/` (`package-mac.sh`, 2026-10-23 at 05:13 UTC): the universal Civ64.app signed with the
Developer ID, `Civ64-1.2.1-macOS.dmg` notarized (submission `89fbd54b-5ec5-413f-9d00-f02304db2e65`: Accepted, no
issues) and stapled, Gatekeeper accepts the application and the image; NODOS_OK; SHA-256
`3b760888ed83b7a388189535bb7515823b9886ee04694f7f8ffe005f94ae2157`; with the user's game ZIPs and vgasys.fon. It
replaces the MAC4 build (`build/user-builds/mac4/`) for the user's check.

## Not covered

* The user's own keyboard (the Butterfly keyboard): the user's check.
* Other Command shortcuts were not exercised one by one (the same path).

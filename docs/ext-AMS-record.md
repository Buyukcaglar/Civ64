# Extension unit AMS (alternative music and sound effects) - record

## Result

civ64 can play the user's own music and sound effects instead of the Windows game's 24 wave files. A folder or a ZIP
file named MusicSfx (MusicSfx.zip, or a MusicSfx folder, next to civ64.exe; the names compared ignoring case) may hold
any number of those 24 files (names compared ignoring case); each valid WAV file found is played instead of the
game's own file of that name, every other sound is the game's own. A new check item "Alternative music/soundfx" at the
top level of the window menu, below Graphics, is checked automatically when a valid source is found or chosen, and the
player can uncheck (and check) it at any time; the choice is remembered. When no source is found, the first-time setup
asks for one after the DOS question, as the DOS files are asked for (optional; "not now" asks again, "never" stops
asking). The core is unchanged (P0): the replacement happens in the Win32 back end's sound service.

## Status

Staged in `build/ams-stage/` on CRT's staged copies (CRT lands first). Landed 2026-10-19 (see "Landing"). The user's MusicSfx
sources are never needed by the tests and none of their bytes are in the repository or a binary: the tests make
synthetic 48-byte WAV files of their own.

## The user's words

The user's request of 2026-10-17 (verbatim in `docs/verify/BRIEF-extras.md`, item 1), the 24 names, the case-
insensitive matching, the fallback to the original resources, the item "Alternative music/soundfx" (the user's
corrected spelling of 2026-10-17 about 10:30 UTC), "enabled automatically if user provides a valid source, and can be
disabled by user at any thime by unchecking it", "First time setup process shall be same DOS graphics setup and
displayed after asking DOS resource questions". Placement: BRIEF-hm.md (a top-level check item below Graphics).

## Findings (where the sounds are played)

* The game plays every sound through MMSYSTEM sndPlaySound (`platform/w16/user_misc.c w16_sndPlaySound`; the game
  calls it asynchronously at 1150:00BE and stops with a NULL name at 1150:012D, as the file's header records). The
  name resolves through the virtual DOS like a file and `host_play_sound(relpath, async)` plays the data directory's
  file with PlaySoundW. The 24 names are the WAV files of the Windows game's data (the user's list).
* So the replacement sits in `host_play_sound` (platform/win32/host_win32.c): the core's call, its return value and
  every state it sees stay as they are (P0); only the host's playback chooses other bytes.

## Design

* **Lookup** (`win64/civ64_locate.c`, after the DOS steps; civ64_locate.h): 1 `--music-sfx <dir|zip|none>`; 2
  MusicSfx.zip next to civ64.exe; 3 a MusicSfx subfolder; 4 civ64.cfg's `music_data` (a folder or a ZIP); 5 the
  question (unless `music_ask=never`): "Alternative music and sound effects were not found ... Locate them now?"; Yes
  opens the file dialog for a WAV file (its folder is the source) or a ZIP; No asks "Ask again the next time civ64
  starts?" (No writes `music_ask=never`), as the DOS question does. A chosen source is remembered (`music_data`) and
  the item is checked again (the key `alt_sounds` removed).
* **Valid:** a source counts when at least one of the 24 names is a valid WAV file (RIFF WAVE with a "fmt " chunk of
  at least 16 bytes with a format tag, channels and a rate, and a non-empty "data" chunk: `civ64_wav_ok`). In a folder
  the names are looked up in its top level (any case); in a ZIP in any one folder (`zip_find_base`; a name twice in two
  folders is not used). An invalid file of a name is ignored and the game's own file plays. A source without one valid
  file: `--music-sfx` stops civ64 with a message, steps 2..4 skip it, a choice is refused and asked again.
* **In memory:** the valid files are read once at the start into memory (a ZIP is read in memory and never extracted,
  as the DOS ZIP is; nothing is written to %LOCALAPPDATA%), and kept for the run. A source changed or removed while
  civ64 runs takes effect at the next start (the open points of the brief: no refresh during a run; a ZIP replaced
  later is read afresh at the next start).
* **Playback** (`host_play_sound`): the last path component of the game's name, matched to the 24 names ignoring
  ASCII case; with a replacement and the item checked, PlaySoundW plays the replacement's bytes (SND_MEMORY, the
  game's async/sync flag, SND_NODEFAULT); otherwise the game's file as before. The stop (NULL name) stops either.
* **Menu:** top level "A&lternative music/soundfx" (SC_CIV_ALT_SOUNDS 0x1140, check; the id audit: ids to 0x1130 in
  use), between Graphics and the separator above About...; grayed without a valid source; its hook, then the settings
  hook. civ64 writes the key `alt_sounds` ("1"/"0") only after the player's choice; at the start the item is checked
  when a source is valid unless `alt_sounds` is "0".

## Deviations

* F332: an alternative sound is played from memory with PlaySoundW (SND_MEMORY), not from a file of the data
  directory; a WAV file that PlaySoundW cannot decode although its header is valid (an exotic compression without a
  codec) plays nothing.
* F333: the sources are read at the start only; a change while civ64 runs is used at the next start.
* F334: the 24 names are matched by the last component of the game's sound name only (any folder).

## Tests

* `tests/win32/test_locate.c` `test_ams` (about 13 checks): `civ64_wav_ok` (valid, not WAVE, cut, too short, NULL,
  format tag 0); quiet with no source: none, nothing asked; a MusicSfx folder (mixed case) with a valid ALEX.WAV, an
  invalid Cannon.wav and another name: one sound, at alex's index; MusicSfx.zip before the folder with OPENING.WAV in a
  subfolder, S_Beep.wav and an invalid mao.wav: two sounds; `civ64_found_free` frees them; `--music-sfx none`, a WAV
  file's folder, a folder without a valid file (refused, exit message names the 24 files); an invalid folder skipped;
  the remembered ZIP.
* `tests/win32/test_host_win32.c`: the 24 names and their case-insensitive index; the item cannot be checked without
  a replacement (grayed); with one: on, the replacement counted when the game plays ALEX.WAV and Sound\alex.wav, not
  for CANNON.WAV; the command unchecks/checks it with the hook and the settings hook; unchecked plays the game's own;
  the replacement removed: off; the window menu's top level with the new item (15 items); `--music-sfx`.
* The question itself (message boxes and the file dialog of step 5) is not exercised headless (the tests run quiet);
  it is the user's check AMS-2.

## For the records

* DESIGN: 12.x "Alternative music and sound effects" (lookup, validity, memory, playback), 12.2 menu.
* FIDELITY: F332 .. F334.
* RUNNING: `--music-sfx <dir|zip|none>`, MusicSfx.zip / MusicSfx folder, the keys `music_data`, `music_ask`,
  `alt_sounds`; the 24 names; the top-level item.
* FEATURES: host row "Alternative music/soundfx" (both graphics).

## What the user checks

* **AMS-1** Put your MusicSfx.zip (or a MusicSfx folder) next to civ64.exe and start civ64: no question is asked; the
  window menu (the icon at the left of the title bar) shows "Alternative music/soundfx" below "Graphics", checked. The
  opening music and every sound you provided play as your files (for example the opening tune, a battle's cannon, a
  leader's music); sounds you did not provide play as the game's own.
* **AMS-2** Without MusicSfx next to civ64.exe, start civ64 with a fresh settings file (or after removing the keys
  music_data and music_ask from civ64.cfg): after the DOS question civ64 asks "Alternative music and sound effects were
  not found ... Locate them now?". Yes: choose a WAV file inside your folder, or your ZIP: the item is checked and your
  sounds play; the next start asks nothing. No: "Ask again the next time civ64 starts?" (No: never again).
* **AMS-3** Uncheck "Alternative music/soundfx" while playing: the next sounds are the game's own; check it again: your
  sounds again. Close and restart: the item keeps your last choice.
* **AMS-4** File names in any case (OPENING.WAV, Opening.wav) are used; a file that is not a WAV file (rename a text
  file to alex.wav) is ignored and that sound is the game's own; without any valid file civ64 asks again (or, with
  --music-sfx, says that the source has none of the 24 files).
* **AMS-5** Without any source the item is grayed and cannot be checked.

## Expected changes at the build slot

* test_locate + about 13 checks; test_host_win32 + about 12 checks; every other count and golden unchanged (no test
  data has a MusicSfx source; the quiet tests never ask).
* P0 unchanged (the core's sndPlaySound and its result unchanged; host playback only).

## Rebase notes

Bases: `BASE-SHA256.txt` (the tree's files, 2026-10-18 about 21:40 UTC) and `BASE-STAGE-SHA256.txt` (the CRT/A43/WL
stage copies AMS started from; kept in `obj/base-stage/`). After CRT lands, each file is 3-way merged read-only.

## Landing

AMS landed at the build slot of session E5 after CRT (build/crt-prep/LANDED.txt), the cycle ending 2026-10-19.

* **Rebase:** CRT's landed copies equal the CRT stage copies AMS was built on (line endings normalised to the tree's:
  LF, win64/civ64_locate.c CRLF); BASE-SHA256.txt refreshed. Private overlay (tree + AMS) Checked, CheckedNoObs and
  Release BUILD_OK, every unit and Win32-headless test passing. The positional system-menu check of test_host_win32
  (S2/UX1/HM: Close last, About..., the submenus, Full screen) moved by one for the new top-level item.
* **Copy-in** 2026-10-18 23:37:23 UTC (`build/a43-prep/land.py ams --write`, 9 files).
* **The cycle** (`build/ams-status.txt`): 1 `build.cmd checked` BUILD_OK 23:37:33..23:41:14; 2 `test.cmd checked`
  TESTS_OK 23:41:14..00:12:36; 3 `ext_g1.py check` EXT_G1_OK runs 77 unchanged: **ALL_GREEN** 00:12:36 UTC
  (2026-10-19); 4 `build.cmd` (Release) BUILD_OK 00:12:36..00:16:07: **RELEASE_OK**.
* **Against the predictions** (`build/ams-prep/predictions.txt`): test_host_win32 484 -> 495 (+11), test_locate
  36 -> 47 (+11, test_ams); portable sources 312 unchanged; every other test and harness section green as before.
* **User build** `build/user-builds/ams/` (AMS-1..AMS-5): no MusicSfx source is in it (the user's own files are
  used). FIDELITY numbers F332..F334.
* Not done here: the docs pass ("For the records"), the checklist rows and STATUS (the orchestrator's).

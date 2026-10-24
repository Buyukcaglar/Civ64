# Unit MACB3 (the DOS "not found" sentence names Civ64.app on macOS) - record

## The user's words (2026-10-23, about 08:55 UTC)

> update it

(on the item left open by the macOS port of unit DV, [ext-DV-record.md](ext-DV-record.md): on macOS the DOS asset
store's "not found" sentence said "next to civ64.exe").

## Change

* `present/dos/pdos_assets.c`: the sentence names the program through the build setting `CIV_PROGRAM_FILE`, whose
  default is "civ64.exe": "Civilization for DOS was not found (CivDos.zip, Civ-Dos.zip, Civ_Dos.zip or a CivDos
  folder next to " CIV_PROGRAM_FILE ", or --dos-data)." The Windows build (`build.cmd`) does not define it, so its
  sentence and its bytes are unchanged; no platform test (`__APPLE__`, `_WIN32`) enters the portable layers, which
  have none.
* `build-mac.sh`: `-DCIV_PROGRAM_FILE="Civ64.app"` in the flags of every portable source (all variants, both
  architectures).

## Checks (agent-observed, this Mac)

* `build-mac.sh checked` and `release`: BUILD_OK (the c11, c17 and c99 checks of every portable source).
* `registry.py check`: REGISTRY_OK; `test-mac.sh --section unit Checked`: the 64 test programs PASS;
  `--section d2_registry`: REGISTRY_OK.
* The Release application with a remembered DOS copy whose KING00.PIC changed (`dos_data`, `dos_ask=never`, a test
  settings folder) and `--graphics dos`: "Civilization for DOS was not found (CivDos.zip, Civ-Dos.zip, Civ_Dos.zip or
  a CivDos folder next to Civ64.app, or --dos-data)."

## Not covered

* Not in a published build yet: the published `Civ64-1.2.3-macOS.dmg` keeps "civ64.exe" in this sentence; the change
  reaches the next macOS release (it did: `Civ64-1.2.4-macOS.dmg`, `ext-ZS-record.md`, "The macOS port").
* The Windows build was not rebuilt here (nothing of it changes).

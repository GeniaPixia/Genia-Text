# GeniaText 0.8.0 — Russian / English localization

Branch: `develop/0.8.0`. The released `v0.7.0` is frozen.

## Policy
- Auto + Windows UI language ru-* = Russian.
- Auto + any other Windows UI language = English.
- Manual Russian / English overrides Windows UI language.
- User-selected language is stored as an additive settings.json property.
- The interface applies a changed language on restart.
- User phrases, categories, phrase JSON, paste, clipboard and hotkeys are not translated or changed.

## Stages
1. Language policy, settings data model and deterministic tests (this checkpoint).
2. RU/EN dictionaries, Settings language selector, Picker chrome and tray commands (implemented; Windows compilation pending).
3. Recovery, startup, editor and import runtime messages localized. The frozen Picker code-behind retains its original emergency paste-failure message (Core-contract exception). Windows build and UI smoke test pending.
4. Windows build/regression tests, then a separate 0.8 alpha.

## Guard
The five frozen files in CORE-CONTRACT.md are excluded. This commit is not a working UI-language release yet.


## Isolated Windows UI smoke test

Run scripts/Test-Language-0.8.0.ps1 from a clean develop/0.8.0 checkout. The preflight verifies stable tag, frozen Core blobs and Git cleanliness; builds and tests; copies compiled files to a NEW %TEMP% lab directory and writes a TXT transcript. The lab has a portable marker and starts with no copied phrases or settings. The script never starts the app. Close any existing GeniaText process first (single-instance mutex). Test Auto, Russian and English with restarts and check Picker, Settings, editor, recovery, import and system tray. Stable 0.7.0 binaries and user data are not touched.

## Alpha 2 — settings UI polish (pending Windows acceptance)

- Default Settings window height 690 → 598; minimum height 620 → 548.
- General tab's portable/language sections tightened while preserving control IDs
  and all settings semantics.
- Features remains scrollable; cards use smaller paddings and improved 11.5 pt
  description readability (RU and EN).
- App-profile rules tooltip is localized using an additional dictionary key.
- No Core, data model, persistence, hotkey or runtime behavior changes.
- New isolated lab run should confirm visual clipping, keyboard focus and
  both languages before a Beta candidate.

## Alpha 3 — recovery backup display locale polish

The English Recovery screenshot exposed legacy Russian backup reason labels and
file-size units. The UI now translates known backup reason strings and formats
backup sizes via presentation-only WPF converters. Unknown/custom reason values
pass through unchanged. BackupBrowserService, PhraseStore, snapshot filenames,
serialized data, restore and delete logic remain unchanged.

Two pure logic tests cover recognized and unknown reason handling.
This is a development checkpoint pending Windows build and visual acceptance.

## 0.8.0 Beta 1 packaging candidate

Separate candidate package script: scripts/Build-Beta1-Portable.ps1. See BETA1-0.8.0-VALIDATION.md. The 0.7.0 build-portable.ps1 remains untouched. Release gate HOLD pending Windows extracted-ZIP validation.

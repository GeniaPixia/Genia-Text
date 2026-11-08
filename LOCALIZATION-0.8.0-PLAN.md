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
2. RU/EN resources and Settings language selector.
3. Localize every Picker, editor, recovery, import, tray and runtime message.
4. Windows build/regression tests, then a separate 0.8 alpha.

## Guard
The five frozen files in CORE-CONTRACT.md are excluded. This commit is not a working UI-language release yet.

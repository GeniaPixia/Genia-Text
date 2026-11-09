# GeniaText 0.8.0 Beta 1

The first public beta of GeniaText 0.8.0 adds Russian/English interface
localization and refines the Settings layout without changing the frozen Core.

## What's new
- RU/EN interface support with Auto, Russian and English settings.
- Auto follows the Windows UI language (Russian on ru-* systems, English otherwise).
- Translated phrase manager, Picker labels, Settings, Editor Pro, import and
  recovery interface, tray menu and backup reason labels.
- More compact Settings window, scrollable optional feature cards and improved
  readability.
- Existing phrases, categories and user content remain unchanged. User language
  preference is preserved across application restarts.

## Installation
Download `GeniaText-0.8.0-beta.1-portable-win-x64.zip`, extract it to a
separate folder and run `GeniaText.exe`. Keep `GeniaText.portable` beside
the executable. Do not overwrite an existing stable installation folder.

Windows x64; self-contained .NET 10 build, no separate .NET runtime needed.

## Verification
- 25 automated tests passed, 0 failed.
- Portable ZIP integrity and extracted EXE SHA-256 verified.
- Windows launch, Ctrl+Space phrase insertion and persistence of test phrase
  and English language choice after restart: passed.

ZIP SHA-256:
`F5D6731E024A5C4285981E61E355765A7DDE91D9D5DEE8EF39892BE3AF282142`

## Version policy
This is a **pre-release** for testing. GeniaText 0.7.0 remains the stable
version. Core hotkey/paste/store files are unchanged; optional modules remain
disabled by default.

---

# GeniaText 0.8.0 Beta 1 — по-русски

Первая бета-версия 0.8.0: локализация интерфейса на русский и английский,
выбор языка (Авто / Русский / English), компактные настройки и улучшенная
читаемость. Пользовательские фразы не переводятся и не изменяются.

**Установка:** распакуйте ZIP в новую отдельную папку и запустите
`GeniaText.exe`. Файл `GeniaText.portable` должен лежать рядом с EXE.

**Проверено:** 25/25 тестов, SHA-256 архива и программы, запуск на Windows,
вставка через Ctrl+Space, сохранение фразы и выбранного языка после перезапуска.

Это предварительный релиз. Стабильная версия 0.7.0 остаётся без изменений.

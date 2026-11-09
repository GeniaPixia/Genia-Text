# GeniaText 0.8.0 Beta 1 portable candidate

This is a candidate package process, not a published release or tag.

Verified incoming evidence:
- Windows build and self-tests: 25/25 PASS.
- Alpha 3 portable isolation: PASS; Git: CLEAN.
- Windows RU/EN screenshots: Settings, editor, Editor Pro, Recycle bin, backup browser.
- English backup reason labels "Application startup" and "Periodic" confirmed.

Run scripts/Build-Beta1-Portable.ps1 from a clean develop/0.8.0 branch.

Unlike the historical build-portable.ps1 pinned to 0.7.0, this script:
- verifies stable v0.7.0 tag, Git cleanliness and all 5 frozen Core blobs;
- builds with warnings as errors and checks 25/25 self-tests;
- creates a NEW artifacts/beta1-<commit>/ directory, with no overwriting;
- publishes self-contained Windows x64 single-file GeniaText.exe;
- makes a 2-file portable ZIP (GeniaText.exe and GeniaText.portable);
- reads ZIP entries back to verify SHA256 against the packaged source files;
- writes ZIP .sha256 and a separate TXT result transcript;
- does not copy or alter phrase data or settings.

Final validation: extract to a new empty folder, verify ZIP SHA256, close any
running GeniaText, then launch the extracted EXE. Check RU and EN language
selection after restart, Ctrl+Space paste workflow, editor, backup recovery,
portable local settings and phrases. Do not use Stable's data folder.

Release gate remains HOLD until the Windows extracted-ZIP test passes.

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

## Windows release-candidate acceptance (2026-11-09)

Tested source commit: `a7ca8bedadeeede66ad806ecaf10762fad6631ab`. Use THIS commit as the GitHub
pre-release target, even if documentation commits advance develop afterward.

- Windows Release build and self-tests: 25 passed, 0 failed.
- Self-contained single-file publish: PASS.
- ZIP consists of GeniaText.exe and GeniaText.portable: PASS.
- ZIP entries verified against source files by SHA-256: PASS.
- SHA-256 of entire ZIP rechecked before extraction: PASS.
- Extracted EXE hash verified: PASS.
- Launch from extracted ZIP: PASS (user report).
- Ctrl+Space -> select -> paste into another application: PASS (user report).
- Test phrase and manually selected English interface language persisted after
  complete application exit and restart: PASS (user report).
- RU/EN visual inspection and English backup labels: PASS on Alpha 3, whose
  application code remains identical apart from beta version metadata.
- v0.7.0 stable remains unchanged; Git and frozen Core gates: PASS.

Artifacts on the user's Windows PC (not uploaded to GitHub yet):

- `D:\GeniaText\artifacts\beta1-a7ca8be\GeniaText-0.8.0-beta.1-portable-win-x64.zip`
- ZIP SHA-256: `F5D6731E024A5C4285981E61E355765A7DDE91D9D5DEE8EF39892BE3AF282142`
- EXE SHA-256: `2205721501A98344C9BD97D633A62D44616A8E024BAA71E37C5828F3EA14C927`
- Sidecar: ZIP `.sha256` file next to the ZIP.

Status: `BETA1_RUNTIME_SMOKE=PASS`; `READY_FOR_PRERELEASE_ASSET_UPLOAD`.
The GitHub pre-release is NOT published or tagged by this document.

Before publishing: target tag `v0.8.0-beta.1` at the tested commit
`a7ca8bedadeeede66ad806ecaf10762fad6631ab`; upload the exact verified ZIP and the matching .sha256 file,
mark the release as a *pre-release*, and leave v0.7.0 as the latest
stable release. Verify the public assets/checksum after upload.

# GeniaText 0.8.0 alpha — isolated Windows RU/EN laboratory.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$branch = 'develop/0.8.0'
$expectedStable = '982bd95ec969d7da4902cf2e7ea672a16eed1495'
$frozen = @(
 'GeniaText/Services/GlobalHotkey.cs',
 'GeniaText/Services/PasteService.cs',
 'GeniaText/Services/PhraseStore.cs',
 'GeniaText/Services/AppSettingsStore.cs',
 'GeniaText/PickerWindow.xaml.cs'
)
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) { throw '.NET SDK not found' }
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git not found' }

Push-Location $root
try {
 $active = (& git branch --show-current).Trim()
 if ($LASTEXITCODE -ne 0 -or $active -ne $branch) { throw "BRANCH_GATE_FAIL: $active" }
 $dirty = @(& git status --porcelain)
 if ($LASTEXITCODE -ne 0 -or $dirty.Count -gt 0) { throw "GIT_NOT_CLEAN: $($dirty -join '; ')" }
 $stable = (& git rev-parse 'v0.7.0^{commit}').Trim()
 if ($LASTEXITCODE -ne 0 -or $stable -ne $expectedStable) { throw "STABLE_TAG_MISMATCH: $stable" }
 foreach ($p in $frozen) {
  $before = (& git rev-parse "v0.7.0:$p").Trim()
  if ($LASTEXITCODE -ne 0) { throw "STABLE_BLOB_NOT_FOUND: $p" }
  $now = (& git rev-parse "HEAD:$p").Trim()
  if ($LASTEXITCODE -ne 0 -or $now -ne $before) { throw "CORE_MISMATCH: $p" }
 }
 $head = (& git rev-parse HEAD).Trim()
 if ($LASTEXITCODE -ne 0 -or $head.Length -lt 7) { throw 'HEAD_NOT_FOUND' }
 $short = $head.Substring(0,7)
 $lab = Join-Path $env:TEMP "GeniaText-0.8.0-Lab-$short"
 if (Test-Path -LiteralPath $lab) { throw "LAB_ALREADY_EXISTS: $lab" }
 $report = Join-Path $env:TEMP ("GeniaText-0.8.0-$short-{0}-Result.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
 if (Test-Path -LiteralPath $report) { throw "REPORT_ALREADY_EXISTS: $report" }
 Start-Transcript -LiteralPath $report -NoClobber | Out-Null
 try {
  Write-Host '=== GENIATEXT 0.8.0 ISOLATED LAB ==='
  Write-Host "HEAD=$head"
  Write-Host "STABLE_TAG=$stable"
  Write-Host 'CORE_BLOBS=5/5 MATCH'
  Write-Host 'GIT_PREFLIGHT=CLEAN'
  & (Join-Path $root 'build-and-test.ps1') -Configuration 'Release'
  if ($LASTEXITCODE -ne 0) { throw "BUILD_TEST_FAILED: $LASTEXITCODE" }
  $output = Join-Path $root 'GeniaText\bin\Release\net10.0-windows'
  if (-not (Test-Path -LiteralPath (Join-Path $output 'GeniaText.exe'))) {
   throw 'EXPECTED_BUILD_EXE_MISSING'
  }
  New-Item -ItemType Directory -Path $lab -ErrorAction Stop | Out-Null
  Copy-Item -Path (Join-Path $output '*') -Destination $lab -Recurse -Force
  [IO.File]::WriteAllText((Join-Path $lab 'GeniaText.portable'),
   'GeniaText isolated portable lab', (New-Object Text.UTF8Encoding($false)))
  $labExe = Join-Path $lab 'GeniaText.exe'
  if (-not (Test-Path -LiteralPath $labExe)) { throw 'LAB_EXE_MISSING' }
  if (-not (Test-Path -LiteralPath (Join-Path $lab 'GeniaText.portable'))) {
   throw 'PORTABLE_MARKER_MISSING'
  }
  if (@(& git status --porcelain).Count -ne 0) { throw 'GIT_POSTFLIGHT_DIRTY' }
  $hash = (Get-FileHash -LiteralPath $labExe -Algorithm SHA256).Hash
  Write-Host 'BUILD_TEST=PASS'
  Write-Host 'PORTABLE_ISOLATION=PASS'
  Write-Host 'GIT_POSTFLIGHT=CLEAN'
  Write-Host "LAB_EXE=$labExe"
  Write-Host "LAB_EXE_SHA256=$hash"
  Write-Host "REPORT=$report"
  if (Get-Process GeniaText -ErrorAction SilentlyContinue) {
   Write-Host 'SINGLE_INSTANCE_WARNING=Close running GeniaText from the tray before starting the lab EXE.'
  } else {
   Write-Host 'LAB_NOT_LAUNCHED=Launch the isolated EXE manually for RU/EN UI tests.'
  }
 } catch {
  Write-Host "GATE_FAIL=$($_.Exception.Message)"
  throw
 } finally { Stop-Transcript | Out-Null }
} finally { Pop-Location }

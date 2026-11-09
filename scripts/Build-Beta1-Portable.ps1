# GeniaText 0.8.0 Beta 1 - isolated portable candidate (never touches Stable).
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$root = Split-Path -Parent $PSScriptRoot
$branch = 'develop/0.8.0'
$version = '0.8.0-beta.1'
$runtime = 'win-x64'
$stableExpected = '982bd95ec969d7da4902cf2e7ea672a16eed1495'
$frozen = @(
 'GeniaText/Services/GlobalHotkey.cs',
 'GeniaText/Services/PasteService.cs',
 'GeniaText/Services/PhraseStore.cs',
 'GeniaText/Services/AppSettingsStore.cs',
 'GeniaText/PickerWindow.xaml.cs'
)
$report = Join-Path $env:TEMP ("GeniaText-Beta1-{0}-{1}-Result.txt" -f (Get-Date -Format 'yyyyMMdd-HHmmss'), $PID)
if (Test-Path -LiteralPath $report) { throw "REPORT_EXISTS: $report" }
Start-Transcript -LiteralPath $report -NoClobber | Out-Null
try {
 Push-Location $root
 try {
  Write-Host '=== GENIATEXT BETA 1 PORTABLE RELEASE-CANDIDATE GATE ==='
  Write-Host "REPORT=$report"
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'GIT_NOT_FOUND' }
  if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) { throw 'DOTNET_NOT_FOUND' }
  $currentBranch = (& git branch --show-current).Trim()
  if ($LASTEXITCODE -ne 0 -or $currentBranch -ne $branch) { throw "BRANCH_GATE_FAIL: $currentBranch" }
  $dirty = @(& git status --porcelain)
  if ($LASTEXITCODE -ne 0 -or $dirty.Count -ne 0) { throw "GIT_PREFLIGHT_DIRTY: $($dirty -join '; ')" }
  $head = (& git rev-parse HEAD).Trim()
  if ($LASTEXITCODE -ne 0 -or $head.Length -ne 40) { throw 'GIT_HEAD_INVALID' }
  $short = $head.Substring(0,7)
  $stableActual = (& git rev-parse 'v0.7.0^{commit}').Trim()
  if ($LASTEXITCODE -ne 0 -or $stableActual -ne $stableExpected) { throw "STABLE_TAG_CHANGED: $stableActual" }
  foreach ($p in $frozen) {
   $stableBlob = (& git rev-parse "v0.7.0:$p").Trim()
   if ($LASTEXITCODE -ne 0 -or -not $stableBlob) { throw "STABLE_CORE_NOT_FOUND: $p" }
   $devBlob = (& git rev-parse "HEAD:$p").Trim()
   if ($LASTEXITCODE -ne 0 -or $devBlob -ne $stableBlob) { throw "FROZEN_CORE_CHANGED: $p" }
  }
  $project = Join-Path $root 'GeniaText\GeniaText.csproj'
  $projectXml = [IO.File]::ReadAllText($project, [Text.Encoding]::UTF8)
  if (-not $projectXml.Contains("<Version>$version</Version>")) { throw 'PROJECT_VERSION_MISMATCH' }
  $stage = Join-Path $root "artifacts\beta1-$short"
  $publish = Join-Path $stage 'publish'
  $package = Join-Path $stage 'package'
  $zipName = "GeniaText-$version-portable-$runtime.zip"
  $zip = Join-Path $stage $zipName
  $shaFile = "$zip.sha256"
  if (Test-Path -LiteralPath $stage) { throw "STAGE_ALREADY_EXISTS: $stage" }
  Write-Host "HEAD=$head"
  Write-Host "STABLE_TAG=$stableActual"
  Write-Host 'FROZEN_CORE=5/5 MATCH'
  Write-Host 'GIT_PREFLIGHT=CLEAN'

  $solution = Join-Path $root 'GeniaText.sln'
  $tests = Join-Path $root 'GeniaText.Tests\GeniaText.Tests.csproj'
  & dotnet build $solution -c Release -warnaserror
  if ($LASTEXITCODE -ne 0) { throw "BUILD_FAILED: $LASTEXITCODE" }
  $testLines = @(& dotnet run --project $tests -c Release --no-build)
  $testExit = $LASTEXITCODE
  $testLines | ForEach-Object { Write-Host $_ }
  if ($testExit -ne 0) { throw "SELF_TEST_FAILED: $testExit" }
  if (-not ($testLines -match 'GeniaText self-tests: 25 passed, 0 failed\.')) {
   throw 'SELF_TEST_25_0_NOT_CONFIRMED'
  }

  New-Item -ItemType Directory -Path $publish -ErrorAction Stop | Out-Null
  New-Item -ItemType Directory -Path $package -ErrorAction Stop | Out-Null
  & dotnet publish $project -c Release -r $runtime --self-contained true '-p:PublishSingleFile=true' '-p:IncludeNativeLibrariesForSelfExtract=true' '-p:EnableCompressionInSingleFile=true' '-p:PublishTrimmed=false' '-p:PublishReadyToRun=false' '-p:DebugType=None' '-p:DebugSymbols=false' '-p:GeniaTextPortableBuild=true' -o $publish
  if ($LASTEXITCODE -ne 0) { throw "PUBLISH_FAILED: $LASTEXITCODE" }
  $sourceExe = Join-Path $publish 'GeniaText.exe'
  $sourceMarker = Join-Path $publish 'GeniaText.portable'
  if (-not (Test-Path -LiteralPath $sourceExe -PathType Leaf)) { throw 'PUBLISH_EXE_MISSING' }
  if (-not (Test-Path -LiteralPath $sourceMarker -PathType Leaf)) { throw 'PUBLISH_MARKER_MISSING' }
  $targetExe = Join-Path $package 'GeniaText.exe'
  $targetMarker = Join-Path $package 'GeniaText.portable'
  Copy-Item -LiteralPath $sourceExe -Destination $targetExe -ErrorAction Stop
  Copy-Item -LiteralPath $sourceMarker -Destination $targetMarker -ErrorAction Stop
  $packageNames = @(Get-ChildItem -LiteralPath $package -File | ForEach-Object { $_.Name } | Sort-Object)
  if (($packageNames -join '|') -cne 'GeniaText.exe|GeniaText.portable') {
   throw "PACKAGE_FILES_INVALID: $($packageNames -join ',')"
  }
  Compress-Archive -LiteralPath @($targetExe, $targetMarker) -DestinationPath $zip -CompressionLevel Optimal -ErrorAction Stop
  if (-not (Test-Path -LiteralPath $zip -PathType Leaf)) { throw 'BETA_ZIP_MISSING' }

  Add-Type -AssemblyName System.IO.Compression
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  $archive = [IO.Compression.ZipFile]::OpenRead($zip)
  try {
   $entries = @($archive.Entries | ForEach-Object { $_.FullName } | Sort-Object)
   if ($entries.Count -ne 2 -or ($entries -join '|') -cne 'GeniaText.exe|GeniaText.portable') {
    throw "ZIP_CONTENTS_INVALID: $($entries -join ',')"
   }
   foreach ($entry in $archive.Entries) {
    $source = Join-Path $package $entry.FullName
    if ($entry.Length -ne (Get-Item -LiteralPath $source).Length) { throw "ZIP_LENGTH_MISMATCH: $($entry.FullName)" }
    $stream = $entry.Open()
    $hashObj = [Security.Cryptography.SHA256]::Create()
    try {
     $entrySha = [BitConverter]::ToString($hashObj.ComputeHash($stream)).Replace('-','')
    } finally {
     $hashObj.Dispose()
     $stream.Dispose()
    }
    $sourceSha = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash
    if ($entrySha -cne $sourceSha) { throw "ZIP_ENTRY_SHA256_MISMATCH: $($entry.FullName)" }
   }
  } finally { $archive.Dispose() }

  $zipSha = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
  [IO.File]::WriteAllText($shaFile, "$zipSha  $zipName" + [Environment]::NewLine, [Text.Encoding]::ASCII)
  if ([IO.File]::ReadAllText($shaFile, [Text.Encoding]::ASCII).Trim() -cne "$zipSha  $zipName") {
   throw 'SHA256_MANIFEST_INVALID'
  }
  $dirtyAfter = @(& git status --porcelain)
  if ($LASTEXITCODE -ne 0 -or $dirtyAfter.Count -ne 0) { throw 'GIT_POSTFLIGHT_DIRTY' }
  $headAfter = (& git rev-parse HEAD).Trim()
  if ($LASTEXITCODE -ne 0 -or $headAfter -ne $head) { throw 'GIT_HEAD_CHANGED' }

  Write-Host 'BUILD_TEST=25/25 PASS'
  Write-Host 'SELF_CONTAINED_SINGLE_FILE=PASS'
  Write-Host 'ZIP_CONTENTS=2/2 PASS'
  Write-Host 'ZIP_ENTRIES_SHA256=PASS'
  Write-Host 'STABLE_0_7_0=UNTOUCHED'
  Write-Host 'GIT_POSTFLIGHT=CLEAN'
  Write-Host "BETA_ZIP=$zip"
  Write-Host "BETA_ZIP_SHA256=$zipSha"
  Write-Host "BETA_SHA256_FILE=$shaFile"
  Write-Host "BETA_EXE_SHA256=$((Get-FileHash -LiteralPath $targetExe -Algorithm SHA256).Hash)"
  Write-Host 'RELEASE_GATE=HOLD_PENDING_WINDOWS_EXTRACTION_SMOKE'
 } finally { Pop-Location }
} catch {
 Write-Host "GATE_FAIL=$($_.Exception.Message)"
 throw
} finally {
 Stop-Transcript | Out-Null
}

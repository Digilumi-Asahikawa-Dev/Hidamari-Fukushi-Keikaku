$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'node-runtime.ps1')
$previousNodePath = $env:HIDAMARI_NODE_PATH
$previousPath = $env:PATH
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('hidamari-node-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot | Out-Null
$passed = 0

function Assert-Rejected {
  param([string] $Path, [string] $ExpectedMessage)
  $env:HIDAMARI_NODE_PATH = $Path
  try {
    $null = Get-HidamariNodePath
  } catch {
    if ($_.Exception.Message -notlike "*$ExpectedMessage*") { throw }
    Write-Host "PASS: $ExpectedMessage"
    return
  }
  throw "Expected runtime rejection for $Path"
}

try {
  $approvedNode = Get-HidamariNodePath
  $passed++
  foreach ($version in @('24.19.0', '24.22.0', '22.23.4', '25.0.0', '26.12.1', '24.22.1-rc.1')) {
    # Version stubs are batch files, never old Node.js binaries.
    $stub = Join-Path $testRoot "node-$version.cmd"
    [IO.File]::WriteAllText($stub, "@echo off`r`necho v$version`r`nexit /b 0`r`n")
    $message = if ($version -in @('24.19.0', '24.22.0')) { 'older than' } else { 'stable Node.js 24.x' }
    Assert-Rejected $stub $message
    $passed++
  }
  $newerStub = Join-Path $testRoot 'node-newer.cmd'
  [IO.File]::WriteAllText($newerStub, "@echo off`r`necho v24.23.0`r`nexit /b 0`r`n")
  $env:HIDAMARI_NODE_PATH = $newerStub
  if ((Get-HidamariNodePath) -ne $newerStub) { throw 'A newer stable 24.x patch was rejected.' }
  $passed++
  Assert-Rejected (Join-Path $testRoot 'missing.exe') 'Install Node.js'
  $passed++
  Assert-Rejected './relative-node.exe' 'Install Node.js'
  $passed++

  $bundleRoot = Join-Path $testRoot 'codex-runtimes'
  New-Item -ItemType Directory -Path $bundleRoot | Out-Null
  $bundleStub = Join-Path $bundleRoot 'node.cmd'
  $marker = Join-Path $testRoot 'bundled-runtime-started.txt'
  [IO.File]::WriteAllText($bundleStub, "@echo off`r`necho started > `"$marker`"`r`necho v24.22.1`r`n")
  Assert-Rejected $bundleStub 'bundled Node.js is not approved'
  if (Test-Path -LiteralPath $marker) { throw 'The bundled runtime was probed before rejection.' }
  $passed++

  # A PATH entry must not override the explicitly selected executable.
  $env:HIDAMARI_NODE_PATH = $approvedNode
  $env:PATH = $bundleRoot + [IO.Path]::PathSeparator + $previousPath
  if ((Get-HidamariNodePath) -ne $approvedNode) { throw 'PATH replaced the approved Node.js.' }
  if (Test-Path -LiteralPath $marker) { throw 'The PATH runtime was started.' }
  $passed++

  $fixtureTools = Join-Path $testRoot 'tools'
  $fixturePnpm = Join-Path $testRoot '.build-tools/node_modules/pnpm'
  New-Item -ItemType Directory -Path $fixtureTools, $fixturePnpm | Out-Null
  Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'run-pnpm.ps1'), (Join-Path $PSScriptRoot 'node-runtime.ps1') -Destination $fixtureTools
  [IO.File]::WriteAllText((Join-Path $testRoot 'package.json'), '{"packageManager":"pnpm@11.7.0"}')
  [IO.File]::WriteAllText((Join-Path $fixturePnpm 'package.json'), '{"name":"pnpm","version":"0.0.0"}')
  try {
    $ErrorActionPreference = 'Continue'
    $pnpmOutput = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $fixtureTools 'run-pnpm.ps1') --version 2>&1 | Out-String
    $pnpmExitCode = $LASTEXITCODE
  } finally {
    $ErrorActionPreference = 'Stop'
  }
  if ($pnpmExitCode -eq 0 -or $pnpmOutput -notlike '*Install pnpm@11.7.0*') {
    throw 'A pnpm version mismatch did not stop before its entry point was loaded.'
  }
  $passed++
  Write-Host "Node.js runtime checks passed: $passed"
} finally {
  $env:HIDAMARI_NODE_PATH = $previousNodePath
  $env:PATH = $previousPath
  # Delete only the unique test directory created above, after containment validation.
  $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
  if (-not [IO.Path]::GetFullPath($testRoot).StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'The runtime test directory is outside the temporary directory.'
  }
  Remove-Item -LiteralPath $testRoot -Recurse -Force
}

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
    $message = if ($version -in @('24.19.0', '24.22.0')) { 'older than' } else { 'stable Node.js 24.x' }
    $rejected = $false
    try { Assert-HidamariNodeVersion $version } catch {
      if ($_.Exception.Message -notlike "*$message*") { throw }
      $rejected = $true
    }
    if (-not $rejected) { throw "Unsupported Node.js version accepted: $version" }
    $passed++
  }
  Assert-HidamariNodeVersion '24.23.0'
  $passed++
  Assert-Rejected (Join-Path $testRoot 'missing.exe') 'Install Node.js'
  $passed++
  Assert-Rejected './relative-node.exe' 'Install Node.js'
  $passed++

  $bundleRoot = Join-Path $testRoot 'codex-runtimes'
  New-Item -ItemType Directory -Path $bundleRoot | Out-Null
  $bundleStub = Join-Path $bundleRoot 'node.exe'
  [IO.File]::WriteAllText($bundleStub, 'This is not an executable.')
  Assert-Rejected $bundleStub 'bundled Node.js is not approved'
  $passed++

  # A PATH entry must not override the explicitly selected executable.
  $env:HIDAMARI_NODE_PATH = $approvedNode
  $env:PATH = $bundleRoot + [IO.Path]::PathSeparator + $previousPath
  if ((Get-HidamariNodePath) -ne $approvedNode) { throw 'PATH replaced the approved Node.js.' }
  $passed++

  $wrapperStub = Join-Path $testRoot 'node.cmd'
  [IO.File]::WriteAllText($wrapperStub, '@echo off')
  Assert-Rejected $wrapperStub 'command wrappers are not allowed'
  $passed++
  $fakeDirectory = Join-Path $testRoot 'standalone'
  New-Item -ItemType Directory -Path $fakeDirectory | Out-Null
  $fakeNode = Join-Path $fakeDirectory 'node.exe'
  [IO.File]::WriteAllText($fakeNode, 'This is not a Node.js executable.')
  Assert-Rejected $fakeNode 'not an official Node.js executable'
  $passed++
  $linkedDirectory = Join-Path $testRoot 'linked-node'
  New-Item -ItemType Junction -Path $linkedDirectory -Target $fakeDirectory | Out-Null
  Assert-Rejected (Join-Path $linkedDirectory 'node.exe') 'links are not allowed'
  $passed++

  $childPath = Get-HidamariNodeChildPath $approvedNode ('C:\sample\codex-runtimes\runtime\dependencies\bin\fallback;C:\sample\codex-runtimes\runtime\dependencies\node\bin;C:\sample\codex-runtimes\runtime\dependencies\native\git\cmd;C:\Windows\System32')
  if ($childPath -match 'dependencies\\(bin|node)\\' -or $childPath -notmatch 'native\\git\\cmd') {
    throw 'Child PATH did not remove bundled launchers while preserving other tools.'
  }
  $passed++
  $env:HIDAMARI_NODE_PATH = $approvedNode
  function Get-Item {
    param([string] $LiteralPath, [switch] $Force)
    [pscustomobject] @{ Attributes = [IO.FileAttributes]::Archive; Parent = $null; VersionInfo = [pscustomobject] @{ OriginalFilename = 'node.exe'; ProductVersion = '24.19.0' } }
  }
  try { Assert-Rejected $approvedNode 'older than' } finally { Remove-Item Function:Get-Item }
  $passed++
  function Get-AuthenticodeSignature { param([string] $LiteralPath) [pscustomobject] @{ Status = 'HashMismatch' } }
  try { Assert-Rejected $approvedNode 'valid OpenJS Foundation signature' } finally { Remove-Item Function:Get-AuthenticodeSignature }
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

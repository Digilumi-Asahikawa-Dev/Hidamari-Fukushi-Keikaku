$pnpmArguments = $args
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
. (Join-Path $PSScriptRoot 'node-runtime.ps1')
$nodePath = Get-HidamariNodePath
$project = Get-Content -LiteralPath (Join-Path $repoRoot 'package.json') -Raw | ConvertFrom-Json
$pnpmRoot = Join-Path $repoRoot '.build-tools/node_modules/pnpm'
$pnpmManifest = Join-Path $pnpmRoot 'package.json'
if (-not (Test-Path -LiteralPath $pnpmManifest -PathType Leaf)) {
  throw 'Install the project pnpm into .build-tools as described in README.md.'
}
$pnpm = Get-Content -LiteralPath $pnpmManifest -Raw | ConvertFrom-Json
if ($pnpm.name -ne 'pnpm' -or "pnpm@$($pnpm.version)" -ne $project.packageManager) {
  throw "Install $($project.packageManager) into .build-tools as described in README.md."
}
$pnpmScript = Join-Path $pnpmRoot $pnpm.bin.pnpm
if (-not (Test-Path -LiteralPath $pnpmScript -PathType Leaf)) {
  throw "The pnpm JavaScript entry point was not found: $pnpmScript"
}

$previousPath = $env:PATH
$previousNodeExecPath = $env:npm_node_execpath
$previousNpmExecPath = $env:npm_execpath
Push-Location $repoRoot
try {
  $env:PATH = Get-HidamariNodeChildPath $nodePath $previousPath
  $env:npm_node_execpath = $nodePath
  $env:npm_execpath = $pnpmScript
  & $nodePath $pnpmScript @pnpmArguments
  $pnpmExitCode = $LASTEXITCODE
} finally {
  $env:PATH = $previousPath
  $env:npm_node_execpath = $previousNodeExecPath
  $env:npm_execpath = $previousNpmExecPath
  Pop-Location
}
exit $pnpmExitCode

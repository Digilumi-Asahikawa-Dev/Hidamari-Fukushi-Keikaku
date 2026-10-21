param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $PostcssArgs
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$postcssScript = Join-Path $repoRoot "node_modules\postcss-cli\index.js"

if (-not (Test-Path -LiteralPath $postcssScript)) {
  Write-Error "PostCSS CLI is not installed. Run './tools/run-pnpm.ps1 install --frozen-lockfile' first."
}

. (Join-Path $PSScriptRoot 'node-runtime.ps1')
$nodePath = Get-HidamariNodePath

& $nodePath $postcssScript @PostcssArgs
exit $LASTEXITCODE

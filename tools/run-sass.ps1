param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $SassArgs
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$sassScript = Join-Path $repoRoot "node_modules\sass\sass.js"

if (-not (Test-Path -LiteralPath $sassScript)) {
  Write-Error "Sass is not installed. Run './tools/run-pnpm.ps1 install --frozen-lockfile' first."
}

. (Join-Path $PSScriptRoot 'node-runtime.ps1')
$nodePath = Get-HidamariNodePath

& $nodePath $sassScript @SassArgs
exit $LASTEXITCODE

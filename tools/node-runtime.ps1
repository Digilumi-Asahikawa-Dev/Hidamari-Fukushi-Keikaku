function Get-HidamariNodePath {
  $nodePath = $env:HIDAMARI_NODE_PATH
  if ([string]::IsNullOrWhiteSpace($nodePath)) {
    $nodePath = Join-Path $env:ProgramFiles 'nodejs/node.exe'
  }

  if (-not [IO.Path]::IsPathRooted($nodePath) -or
      -not (Test-Path -LiteralPath $nodePath -PathType Leaf)) {
    throw 'Install Node.js 24.22.1 or a newer 24.x patch, or set HIDAMARI_NODE_PATH to its absolute path.'
  }
  $nodePath = (Resolve-Path -LiteralPath $nodePath).Path
  if ($nodePath -match '[\\/]codex-runtimes[\\/]') {
    throw 'The Codex bundled Node.js is not approved for this project. Set HIDAMARI_NODE_PATH to an updated standalone Node.js.'
  }

  [string] $versionOutput = & $nodePath --version
  if ($LASTEXITCODE -ne 0 -or $versionOutput -notmatch '^v(24\.\d+\.\d+)$') {
    throw 'This project requires a stable Node.js 24.x release (24.22.1 or newer).'
  }
  if ([version] $Matches[1] -lt [version] '24.22.1') {
    throw "Node.js $versionOutput is older than the required security release 24.22.1."
  }

  Write-Host "Node.js: $nodePath ($versionOutput)"
  return $nodePath
}

function Assert-HidamariNodeVersion {
  param([string] $Version)
  if ($Version -notmatch '^24\.\d+\.\d+$') {
    throw 'This project requires a stable Node.js 24.x release (24.22.1 or newer).'
  }
  if ([version] $Version -lt [version] '24.22.1') {
    throw "Node.js $Version is older than the required security release 24.22.1."
  }
}

function Get-HidamariNodeChildPath {
  param([string] $NodePath, [string] $CurrentPath = $env:PATH)
  $entries = @($CurrentPath -split [IO.Path]::PathSeparator | Where-Object {
    $_ -and $_ -notmatch '[\\/]codex-runtimes[\\/].*[\\/]dependencies[\\/](node|bin)([\\/]|$)'
  })
  return (@((Split-Path -Parent $NodePath)) + $entries) -join [IO.Path]::PathSeparator
}

function Get-HidamariNodePath {
  $nodePath = $env:HIDAMARI_NODE_PATH
  if ([string]::IsNullOrWhiteSpace($nodePath)) {
    $nodePath = Join-Path $env:ProgramFiles 'nodejs/node.exe'
  }

  if ($nodePath -notmatch '^[a-zA-Z]:[\\/]' -or
      -not (Test-Path -LiteralPath $nodePath -PathType Leaf)) {
    throw 'Install Node.js 24.22.1 or a newer 24.x patch, or set HIDAMARI_NODE_PATH to its absolute path.'
  }
  $nodePath = (Resolve-Path -LiteralPath $nodePath).Path
  if ($nodePath -match '[\\/]codex-runtimes[\\/]') {
    throw 'The Codex bundled Node.js is not approved for this project. Set HIDAMARI_NODE_PATH to an updated standalone Node.js.'
  }

  if ([IO.Path]::GetFileName($nodePath) -ine 'node.exe') {
    throw 'Only an official node.exe executable is allowed; command wrappers are not allowed.'
  }
  $nodeFile = Get-Item -LiteralPath $nodePath -Force
  $pathItem = $nodeFile
  while ($null -ne $pathItem) {
    if ($pathItem.Attributes -band [IO.FileAttributes]::ReparsePoint) {
      throw 'Node.js file and directory links are not allowed. Use the standalone installation directly.'
    }
    $pathItem = if ($pathItem -is [IO.FileInfo]) { $pathItem.Directory } else { $pathItem.Parent }
  }

  # Inspect metadata before executing even --version, so an old binary never starts.
  if ($nodeFile.VersionInfo.OriginalFilename -ine 'node.exe') {
    throw 'The selected file is not an official Node.js executable.'
  }
  $fileVersion = $nodeFile.VersionInfo.ProductVersion
  Assert-HidamariNodeVersion $fileVersion
  $signature = Get-AuthenticodeSignature -LiteralPath $nodePath
  if ($signature.Status -ne 'Valid' -or
      $signature.SignerCertificate.GetNameInfo([Security.Cryptography.X509Certificates.X509NameType]::SimpleName, $false) -ne 'OpenJS Foundation') {
    throw 'Node.js must have a valid OpenJS Foundation signature. Runtime validation cannot be skipped.'
  }

  [string] $versionOutput = & $nodePath --version
  if ($LASTEXITCODE -ne 0 -or $versionOutput -cne "v$fileVersion") {
    throw 'Node.js runtime version does not match its validated file metadata.'
  }

  Write-Host "Node.js: $nodePath ($versionOutput)"
  return $nodePath
}

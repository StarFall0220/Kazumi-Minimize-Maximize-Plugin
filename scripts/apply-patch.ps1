<#
.SYNOPSIS
    Clone Kazumi 2.3.9 and apply the window-controls patch.

.EXAMPLE
    .\scripts\apply-patch.ps1

.EXAMPLE
    .\scripts\apply-patch.ps1 -Version 2.3.9 -Target D:\src\Kazumi
#>
[CmdletBinding()]
param(
    [string]$Version = '2.3.9',
    [string]$Target = '.\Kazumi'
)

$ErrorActionPreference = 'Stop'

$patch = Join-Path $PSScriptRoot '..\patch\window-buttons.patch'
if (-not (Test-Path $patch)) {
    throw "Patch not found: $patch"
}

if (Test-Path $Target) {
    throw "Target already exists: $Target. Remove it or choose another -Target."
}

Write-Host "Cloning Kazumi $Version into $Target ..."
git clone --branch $Version --depth 1 https://github.com/Predidit/Kazumi.git $Target
if ($LASTEXITCODE -ne 0) {
    throw "git clone failed with exit code $LASTEXITCODE"
}

Write-Host "Applying $patch ..."
git -C $Target apply $patch
if ($LASTEXITCODE -ne 0) {
    throw "git apply failed with exit code $LASTEXITCODE"
}

Write-Host ''
Write-Host 'Patched successfully. Next steps:' -ForegroundColor Green
Write-Host "  cd $Target"
Write-Host '  flutter pub get'
Write-Host '  flutter build windows --release'

# PowerShell equivalent of update_version.sh for local use on Windows.
# Updates the version string in manifest.xml and SailStartupApp.mc.
# Usage:  ./scripts/update_version.ps1 0.2.0

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidatePattern('^\d+\.\d+\.\d+$')]
    [string]$Version
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$manifest = Join-Path $repoRoot 'SailStartup/manifest.xml'
$appFile  = Join-Path $repoRoot 'SailStartup/source/SailStartupApp.mc'

# 1. manifest.xml — only touch the <iq:application ... version="..."> attribute,
#    not the XML declaration's version="1.0".
$manifestText = Get-Content -Raw -Path $manifest
$manifestNew  = [regex]::Replace(
    $manifestText,
    '(<iq:application[^>]*version=")[\d.]+(")',
    "`${1}$Version`${2}"
)
Set-Content -Path $manifest -Value $manifestNew -NoNewline

# 2. SailStartupApp.mc — replace VERSION = "x.y.z"
$appText = Get-Content -Raw -Path $appFile
$appNew  = [regex]::Replace(
    $appText,
    'VERSION\s*=\s*"[\d.]+"',
    "VERSION = `"$Version`""
)
Set-Content -Path $appFile -Value $appNew -NoNewline

Write-Host "Version updated to $Version in manifest.xml and SailStartupApp.mc"

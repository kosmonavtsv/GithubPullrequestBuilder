<#
.SYNOPSIS
    Add 1 to the revision
#>
[CmdletBinding()]
param (
    # This is where the module manifest lives
    [Parameter(Mandatory)]
    [string]$ManifestPath,
    [Parameter(Mandatory)]
    [int]$BuildNumber
)
$ErrorActionPreference = "Stop"

$manifestRaw = Get-Content $ManifestPath -Raw
$manifest = $manifestRaw | ConvertFrom-Metadata
[System.Version]$version = $manifest.ModuleVersion
Write-Output "Old Version: $version"

[String]$newVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, $BuildNumber)
Write-Output "New Version: $newVersion"

$manifest.ModuleVersion = $newVersion

$manifest | ConvertTo-Metadata | Set-Content -Path $ManifestPath -Encoding UTF8
Test-ModuleManifest $ManifestPath | Out-Null

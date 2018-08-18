[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ManifestPath
)
$manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Metadata
[System.Version]$version = $manifest.ModuleVersion
$version
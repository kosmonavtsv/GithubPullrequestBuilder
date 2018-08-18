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
PROCESS {
    $manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Metadata
    [System.Version]$version = $manifest.ModuleVersion
    Write-Output "Old Version: $version"

    [String]$newVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, $BuildNumber)
    Write-Output "New Version: $newVersion"

    $manifest.ModuleVersion = $newVersion
    $manifest.NestedModules = Get-NestedModulesList

    $manifest | ConvertTo-Metadata | Set-Content -Path $ManifestPath -Encoding UTF8
    Test-ModuleManifest $ManifestPath | Out-Null
}

BEGIN {
    $ErrorActionPreference = "Stop"
    function Get-NestedModulesList() {
        [CmdletBinding()]
        [OutputType([string[]])]

        $nestedModuleFolders = @('main', 'configuration', 'git', 'jira', 'github')
        $mofuleFolder = Resolve-Path $ManifestPath | Split-Path -Parent
        [string[]]$nestedModules = $nestedModuleFolders `
            | % {Get-ChildItem ".\GithubPRBuilder\$_\*.psm1"}`
            | % {$_ -replace [regex]::escape($mofuleFolder), '.'}
        $nestedModules
    }
}
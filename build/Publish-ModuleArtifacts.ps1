[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ArtifactRoot,
    [Parameter(Mandatory)]
    [string]$ModuleRoot
)
if (Test-Path -Path $ArtifactRoot) {
    Remove-Item -Path $ArtifactRoot -Recurse -Force
}

New-Item -Path $ArtifactRoot -ItemType Directory | Out-Null

# Copy the module into the dist folder
Copy-Item -Path $ModuleRoot -Destination $ArtifactRoot -Recurse

# Remove the private and public folders from the distribution and the developer .psm1 file.
Get-ChildItem -Path $ArtifactRoot\GithubPRBuilder\*.psm1 -Recurse | Remove-Item -Force
Get-ChildItem -Path $ArtifactRoot\GithubPRBuilder\*.ps1 -Recurse | Remove-Item -Force

# Remove empty folders
do {
    $dirs = Get-ChildItem $ArtifactRoot\GithubPRBuilder -directory -recurse `
        | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } `
        | Select -ExpandProperty FullName
    $dirs | Foreach-Object { Remove-Item $_ }
} while ($dirs.count -gt 0)

# Construct the distributed .psm1 file.
.\build\New-ModulePSMFile.ps1 -ModuleRoot $ModuleRoot -ArtifactRoot $ArtifactRoot
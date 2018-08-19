[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$ArtifactRoot,
    [Parameter(Mandatory)]
    [string]$ModuleRoot
)
$moduleFile = New-Item -Path $ArtifactRoot\GithubPRBuilder\PSModule.psm1 -ItemType File -Force
$Functions = @( Get-ChildItem -Path $ModuleRoot\*.psm1 -Recurse -ErrorAction SilentlyContinue )
Get-Content $Functions | Out-String | Out-File -FilePath $moduleFile -Append

# Write end part of module
Get-Content $ModuleRoot\EndPartOfModule.ps1 | Out-String | Out-File -FilePath $moduleFile -Append

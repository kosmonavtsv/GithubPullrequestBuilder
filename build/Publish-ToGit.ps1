<#
.SYNOPSIS
    Publish the new version back to Master on GitHub
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]$Branch,
    [Parameter(Mandatory)]
    [string]$ModuleVersion
)
Set-StrictMode -Version Latest

Try {
    # Set up a path to the git.exe cmd, import posh-git to give us control over git, and then push changes to GitHub
    # Note that "update version" is included in the appveyor.yml file's "skip a build" regex to avoid a loop
    Import-Module posh-git -ErrorAction Stop
    git checkout $Branch
    git add --all
    git status
    git commit -s -m "Update version to $ModuleVersion"
    git push origin $Branch
    Write-Output "GithubPRBuilder PowerShell Module version $ModuleVersion published to GitHub." -ForegroundColor Cyan
}
Catch {
    # Sad panda; it broke
    Write-Error "Publishing update $ModuleVersion to GitHub failed."
    throw $_
}
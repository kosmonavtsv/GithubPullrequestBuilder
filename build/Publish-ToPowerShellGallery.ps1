<#
.SYNOPSIS
    Publish to the PowerShell Gallery
#>
[CmdletBinding(SupportsShouldProcess)]
param (
    # This is where the module manifest lives
    [Parameter(Mandatory)]
    [string]$NuGetApiKey,
    [Parameter(Mandatory)]
    [string]$ModuleRoot
)

Try {
    # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
    $PM = @{
        Path        = $ModuleRoot
        NuGetApiKey = $NuGetApiKey
        ErrorAction = 'Stop'
    }
    Publish-Module @PM
    Write-Output "GithubPRBuilder PowerShell Module published to the PowerShell Gallery." -ForegroundColor Cyan
}
Catch {
    # Sad panda; it broke
    Write-Error "Publishing module to the PowerShell Gallery failed."
    throw $_
}
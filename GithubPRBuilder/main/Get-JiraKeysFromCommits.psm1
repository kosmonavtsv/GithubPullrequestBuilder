function Get-JiraKeysFromCommits {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Base
    )
    $commits = Get-GitCommitsDiff -Target $Target -Base "origin/$Base"
    $commits `
        | ? {$_.Title -match 'CASEM-\d+' } `
        | % {$Matches[0]} `
        | select -Unique
}
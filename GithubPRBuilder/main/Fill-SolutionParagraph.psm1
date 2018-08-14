function Fill-SolutionParagraph {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Base,
        [Parameter(Mandatory)]
        [string]$Template
    )
    [GitCommit[]] $commits = Get-GitCommitsDiff -Target $Target -Base "origin/$Base"
    $solutions = $commits | % {
        $body = "* $($_.Title.TrimEnd('.'))."
        if ($_.Description) {
            $body += "`r`n`r`n$($_.Description)"
        }
        $body
    }
    $solutionParagraph = [string]::Join("`r`n", $solutions)
    $Template -replace '<solution>', $solutionParagraph
}
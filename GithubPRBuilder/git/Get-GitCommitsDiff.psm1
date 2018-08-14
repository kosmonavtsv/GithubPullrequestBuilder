function Get-GitCommitsDiff {
    [CmdletBinding()]
    [OutputType([GitCommit[]])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Target = "HEAD",
        [Parameter(Mandatory = $false)]
        [string]$Base = "develop"
    )
    # We use delimiters, since the text can contain a carriage return code
    # %s - commit's title
    # %b - commit's description
    $logFormat = "%s<commit_head_end>%b<commit_end>"
    $log = Get-GitLog -Target $Target -Base $Base -LogFormat $logFormat
    $commits = $log.Split(@("<commit_end>"), [System.StringSplitOptions]::RemoveEmptyEntries) 
    #| % {$_.Trim("`r`n")}
    foreach ($commit in $commits) {
        $commitParts = $commit -split "<commit_head_end>"
        [GitCommit]::new($commitParts[0], $commitParts[1])
    }
}
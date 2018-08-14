function Get-GitBranchName {
    param(
        [Parameter(Mandatory = $false)]
        [string]$BranchRef = "HEAD"
    )

    $branch = $BranchRef
    if ($BranchRef -eq "HEAD") {
        $branch = (git rev-parse --abbrev-ref HEAD)
    }
    $branch
}
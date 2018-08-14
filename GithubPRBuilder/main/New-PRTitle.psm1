function New-PRTitle {
    param(
        [Parameter(Mandatory = $false)]
        [string]$TargetBranch = "HEAD",
        [Parameter(Mandatory = $false)]
        [string]$Base = "develop"
    )
    $title = $targetBranch
    if ($targetBranch -match 'CASEM-\d+') {
        $issueKey = $Matches[0]
        # Get jira issue name
        try {
            $branchIssue = Get-JiraIssue -IssueKey $issueKey
        }
        catch {
            Write-Warning "jira issue $_ not found"
        }
        if ($branchIssue) {
            $title = "$targetBranch $($branchIssue.fields.summary)"
        }
    }
    Write-Verbose "PR Title:`r`n$title"
    return $title
}
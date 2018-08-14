function Get-JiraIssueSafe {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$JiraKey
    )
    try {
        Get-JiraIssue -IssueKey $JiraKey
    }
    catch {
        Write-Warning "jira issue $JiraKey not found"
    }
}
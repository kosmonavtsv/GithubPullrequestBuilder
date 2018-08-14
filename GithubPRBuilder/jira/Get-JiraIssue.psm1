function Get-JiraIssue {
    param(
        [Parameter(Mandatory)]
        [string]$IssueKey
    )
    $settings = Import-GithubPRBuilderConfiguration
    $authorizationHeader = New-JiraAuthHeader
    $fullUri = "$($settings.JiraHost)/rest/api/2/issue/$IssueKey"
    $response = Invoke-WebRequest -Uri $fullUri -Headers $authorizationHeader
    ConvertFrom-Json $response.Content
}
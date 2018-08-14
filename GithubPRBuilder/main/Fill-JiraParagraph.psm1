function Fill-JiraParagraph {
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
    function Add-JiraKeyFromBranch([string[]] $JiraKeys) {
        if ($Target -match 'CASEM-\d+') {
            $jiraKeys += $Matches[0]
        }
        $jiraKeys | select -Unique
    }

    function New-JiraParagraph([object[]]$JiraIssues) {
        $jiraParagraph = ''
        $jiraMarkdownLinks = $JiraIssues | % {"* [$($_.fields.summary)](https://jira.parcsis.org/browse/$($_.key))"}
        if ($jiraMarkdownLinks) {
            $jiraParagraph = [string]::Join("`r`n", $jiraMarkdownLinks)
        }
        return $jiraParagraph
    }

    if ($prTemplate.Contains('<jira>')) {
        $jiraKeys = Get-JiraKeysFromCommits -Target $Target -Base $Base
        $jiraKeys = Add-JiraKeyFromBranch -JiraKeys $jiraKeys
        $jiraIssues = $jiraKeys | Get-JiraIssueSafe
        $jiraParagraph = New-JiraParagraph -JiraIssues $jiraIssues
        $Template -replace '<jira>', $jiraParagraph
    }
    else {
        $Template
    }
}
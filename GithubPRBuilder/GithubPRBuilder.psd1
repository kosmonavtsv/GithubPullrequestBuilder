@{
  Copyright = '(c) 2018 kosmonavtsv@gmail.com.'
  PrivateData = @{
    PSData = @{
      ProjectUri = 'https://github.com/kosmonavtsv/GithubPullrequestBuilder'
      Prerelease = 'alpha'
    }
  }
  NestedModules = @('.\main\Fill-JiraParagraph.psm1','.\main\Fill-SolutionParagraph.psm1','.\main\Get-JiraKeysFromCommits.psm1','.\main\New-PRDescription.psm1','.\main\New-PRTitle.psm1','.\configuration\Get-ModulePRTemplate.psm1','.\configuration\Import-GithubPRBuilderConfiguration.psm1','.\configuration\Set-GithubPRBuilderConfiguration.psm1','.\configuration\Update-GithubPRBuilderConfiguration.psm1','.\git\Get-GitBranchName.psm1','.\git\Get-GitCommitsDiff.psm1','.\git\Get-GitLog.psm1','.\git\Get-GitRepositoryName.psm1','.\git\GitCommit.psm1','.\jira\Get-JiraIssue.psm1','.\jira\Get-JiraIssueSafe.psm1','.\jira\New-JiraAuthHeader.psm1','.\github\Get-GithubPRTemplate.psm1','.\github\Send-GitubPullrequest.psm1')
  GUID = 'c72d5a3e-25d9-49c4-b5c6-57d9d94d9e56'
  CompanyName = 'Unknown'
  Description = 'Builder of github pull request'
  Author = 'kosmonavtsv@gmail.com'
  FunctionsToExport = @('Update-GithubPRBuilderConfiguration','New-GithubPullrequest','Set-GithubPRBuilderConfiguration')
  RootModule = '.\New-GithubPullrequest.psm1'
  RequiredModules = @('Configuration')
  ModuleVersion = '1.2.43'
}

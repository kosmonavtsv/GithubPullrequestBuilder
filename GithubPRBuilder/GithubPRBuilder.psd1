@{
  ModuleVersion = '1.2.42'
  RootModule = '.\New-GithubPullrequest.psm1'
  AliasesToExport = @()
  FunctionsToExport = @('Update-GithubPRBuilderConfiguration','New-GithubPullrequest','Set-GithubPRBuilderConfiguration')
  CmdletsToExport = @()
  PrivateData = @{
    PSData = @{
      ProjectUri = 'https://github.com/kosmonavtsv/GithubPullrequestBuilder'
      Prerelease = 'alpha'
    }
  }
  RequiredModules = @('Configuration')
  GUID = 'c72d5a3e-25d9-49c4-b5c6-57d9d94d9e56'
  NestedModules = @()
  Description = 'Builder of github pull request'
  Copyright = '(c) 2018 kosmonavtsv@gmail.com.'
  CompanyName = 'Unknown'
  Author = 'kosmonavtsv@gmail.com'
}

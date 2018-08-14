<#
.SYNOPSIS
    Create pull request
.DESCRIPTION
    Conditions:
        1) You have remote repository with 'origin' alias
        2) You use ssh protocol
.PARAMETER Target
    Branch with changes
.PARAMETER Base
    Base branch
#>
function New-GithubPullrequest {
    [CmdletBinding(SupportsShouldProcess = $True)]
    param(
        [Parameter(Mandatory = $false)]
        [string]$TargetRef = "HEAD",
        [Parameter(Mandatory = $false)]
        [string]$Base = "develop"
    )
    # TODO: refactoring
    # Clear commits cache
    $Script:gitCommitsCache = $null
    $settings = Import-GithubPRBuilderConfiguration

    $ErrorActionPreference = "Stop"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 -bor [System.Net.SecurityProtocolType]::Tls11

    $targetBranch = Get-GitBranchName -BranchRef $TargetRef
    $title = New-PRTitle -TargetBranch $targetBranch
    $description = New-PRDescription -Target $targetBranch -Base $Base
    $repository = Get-GitRepositoryName

    $pull = Send-GitubPullrequest `
        -Owner $settings.GitHubOwner `
        -Repository $repository `
        -Title $title `
        -Body $description `
        -Base $Base `
        -Head $targetBranch

    If ($PSCmdlet.ShouldProcess("Open pull request github page")) {
        Start-Process $pull.html_url
    }
}

# Test for it **during** module import:
try {
    $null = Import-GithubPRBuilderConfiguration
}
catch {
    # Hide the error on import, just warn them
    Write-Warning "You must configure module to avoid this warning on first run. Use Set-GithubPRBuilderConfiguration"
}

$PRTemplate = @"
:ledger: JIRA
--
<jira>

:fire: Задача\Проблема
--
Техническое описание проблемы или задачи.

:bulb: Реализация
--
<solution>

:checkered_flag: Тестирование
--
Какие тесты были написаны или по каким причинам не удалось написать тест.

Зона аффекта
---
Не забыть указать зону аффекта баги в jira задаче. Это особенно необходимо если это баг в `prerelease` или задевает ту функциональность которая уже протестирована в фиче.
"@

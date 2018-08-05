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

function Send-GitubPullrequest {
    [CmdletBinding(supportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Owner,
        [Parameter(Mandatory)]
        [string]$Repository,
        [Parameter(Mandatory)]
        [string]$Title,
        [Parameter(Mandatory)]
        [string]$Head,
        [Parameter(Mandatory)]
        [string]$Base,
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Body
    )
    try {
        $settings = Import-GithubPRBuilderConfiguration
        $postData = @{
            head  = $Head;
            base  = $Base
            title = $Title;
            body  = $Body
        }

        Write-Verbose "PostData = $($postData | Out-String)"

        $params = @{
            Uri         = ("https://api.github.com/repos/$Owner/$Repository/pulls" +
                "?access_token=$($settings.GitHubToken)");
            Method      = 'POST';
            ContentType = 'application/json';
            Body        = [System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $postData -Compress));
        }

        If ($PSCmdlet.ShouldProcess("Invoke-RestMethod $($params | Out-String)")) {
            Invoke-RestMethod @params
        }
    }
    catch {
        Write-Error "An unexpected error occurred $_"
    }
}

function Get-GitRepositoryName {
    $originUrls = (git config --get remote.origin.url)
    $repository = $originUrls `
        | ? {$_ -match ':[^/]*?/(?<rep>.*?)\.git'} `
        | % {$Matches['rep']} `
        | select -First 1
    return $repository
}

function New-PRDescription {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Base
    )
    # return  Get-GithubPRTemplate 
    $prTemplate = Get-ModulePRTemplate
    $prTemplate = Fill-JiraParagraph -Template $prTemplate -Target $Target -Base $Base
    $prTemplate = Fill-SolutionParagraph -Template $prTemplate -Target $Target -Base $Base
    Write-Verbose "PR Description:`r`n$prTemplate"
    $prTemplate
}

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
    $commits = Get-GitCommitsDiff -Target $Target -Base "origin/$Base"
    #Write-Verbose $commits.Count()
    Write-Verbose $commits[0].Title
    $commits = $commits | % {
        $body = "* $($_.Title.TrimEnd('.'))."
        if ($commit.Body) {
            $body += "`r`n`r`n$($_.Body)"
        }
        $body
    }
    $solutionParagraph = [string]::Join("`r`n", $commits)
    $Template -replace '<solution>', $solutionParagraph
}

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

function Get-JiraKeysFromCommits {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Base
    )
    $commits = Get-GitCommitsDiff -Target $Target -Base "origin/$Base"
    $commits `
        | ? {$_.Title -match 'CASEM-\d+' } `
        | % {$Matches[0]} `
        | select -Unique
}

function Get-GithubPRTemplate {
    $gitRoot = (git rev-parse --show-toplevel)
    $template = "$gitRoot\PULL_REQUEST_TEMPLATE.md"
    if (Test-Path $template) {
        Get-Content $template -Encoding UTF8 -Raw
    }
    else {
        ""
    }
}

class GitCommit {
    [string] $Title
    [string] $Description
    GitCommit($Title, $Description) {
        if ($Title) {
            $this.Title = $Title.Trim()
        }
        if ($Description) {
            $this.$Description = $Description.Trim()
        }
    }
}

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

function Get-GitLog {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Base,
        [Parameter(Mandatory)]
        [string]$LogFormat
    )
    if ($Script:log) {
        $log = $Script:log
    }
    else {
        Write-Verbose "git fetch origin $Base"
        $null = (git fetch origin $Base)
        Write-Verbose "git log $Target --not $Base --quiet --pretty=$LogFormat  --reverse"
        $log = (git log $Target --not $Base --quiet --pretty=$LogFormat  --reverse) -join "`r`n"
        # Encoding
        $utf8 = [System.Text.Encoding]::UTF8
        $outputEncoding = [Console]::OutputEncoding
        $log = $utf8.GetString($outputEncoding.GetBytes($log))
        Write-Verbose "GIT COMMITS: $log"
        $Script:log = $log
    }
    return $log
}

function Get-ModulePRTemplate {
    [CmdletBinding()]
    [OutputType([string])]

    $config = Import-GithubPRBuilderConfiguration
    if ($confog.$PRTemplatePath) {
        Get-Content $confog.$PRTemplatePath -Raw
    }
    else {
        $PRTemplate
    }
}

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

function New-JiraAuthHeader {
    $settings = Import-GithubPRBuilderConfiguration
    $bytes = [System.Text.Encoding]::ASCII.GetBytes("$($settings.JiraLogin):$($settings.JiraPassword)")
    $encodedCreds = 'Basic ' + [System.Convert]::ToBase64String($bytes)
    @{Authorization = $encodedCreds}
}

function Import-GithubPRBuilderConfiguration {
    $configuration = Import-Configuration
    $requiredKeys = @('JiraHost', 'JiraLogin', 'JiraPassword', 'GithubToken', 'GithubOwner')
    $notExistedConfigs = $requiredKeys `
        | ? {!$configuration.ContainsKey($_) -or [string]::IsNullOrEmpty($configuration[$_])}

    if ($notExistedConfigs) {
        $congigsStr = [string]::Join(', ', $notExistedConfigs)
        Write-Warning "Thanks for using GithubPRBuilder, configurations not found: $congigsStr, please run Update-GithubPRBuilderConfiguration to configure."
        throw "Module not configured. Run Update-GithubPRBuilderConfiguration"
    }
    $secureString = $configuration.JiraPassword | ConvertTo-SecureString
    $credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList '_', $secureString
    $configuration.JiraPassword = $credential.GetNetworkCredential().Password
    $configuration
}

function Update-GithubPRBuilderConfiguration {
    [CmdletBinding(supportsShouldProcess)]
    param(
        # Jira
        [string]$JiraHost,
        [string]$JiraLogin,
        [switch]$JiraPassword,
        # Github
        [string]$GithubToken,
        [string]$GithubOwner,
        # Other
        [string]$PRTemplatePath
    )
    end {
        If ($PSCmdlet.ShouldProcess("Saving settings to $(Get-ConfigurationPath)")) {
            $config = Import-Configuration
            if (!$config) {
                $config = @{}
            }
            foreach ($parKey in $PSBoundParameters.Keys) {
                $config[$parKey] = $PSBoundParameters[$parKey]
            }
            if ($JiraPassword) {
                $securePassword = (Read-Host "Enter jira password" -AsSecureString | ConvertFrom-SecureString)
                $config.JiraPassword = $securePassword
            }
            $config | Export-Configuration
        }
    }
}

function Set-GithubPRBuilderConfiguration {
    [CmdletBinding(supportsShouldProcess)]
    param(
        # Jira
        [Parameter(Mandatory)]
        [string]$JiraHost,
        [Parameter(Mandatory)]
        [string]$JiraLogin,
        [Parameter(Mandatory)]
        [SecureString]$JiraPassword,
        # Github
        [Parameter(Mandatory)]
        [string]$GithubToken,
        [Parameter(Mandatory)]
        [string]$GithubOwner,
        # Other
        [string]$PRTemplatePath
    )
    end {
        If ($PSCmdlet.ShouldProcess("Saving settings to $(Get-ConfigurationPath)")) {
            $config = Import-Configuration
            if (!$config) {
                $config = @{}
            }
            foreach ($parKey in $PSBoundParameters.Keys | ? {$_ -ne 'JiraPassword'}) {
                $config[$parKey] = $PSBoundParameters[$parKey]
            }
            if ($PSBoundParameters.ContainsKey('JiraPassword')) {
                $securePassword = $JiraPassword | ConvertFrom-SecureString
                $config.JiraPassword = $securePassword
            }
            $config | Export-Configuration
        }
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
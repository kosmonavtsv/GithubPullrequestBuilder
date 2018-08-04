$moduleName = 'GithubPRBuilder'

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
    $description = New-PRDescription
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
    $gitRoot = (git rev-parse --show-toplevel)
    Get-Content "$gitRoot\PULL_REQUEST_TEMPLATE.md" -Encoding UTF8 -Raw
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
        Write-Warning "Thanks for using $moduleName, configurations not found: $congigsStr, please run Update-GithubPRBuilderConfiguration to configure."
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
        [string]$GithubOwner
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
        [string]$GithubOwner
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

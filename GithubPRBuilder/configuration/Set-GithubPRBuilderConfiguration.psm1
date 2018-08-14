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
            $config | Export-Configuration -Module (Get-Module GithubPRBuilder)
        }
    }
}
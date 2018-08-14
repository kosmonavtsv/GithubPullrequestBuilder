function Update-GithubPRBuilderConfiguration() {
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
            $config | Export-Configuration -Module (Get-Module GithubPRBuilder)
        }
    }
}
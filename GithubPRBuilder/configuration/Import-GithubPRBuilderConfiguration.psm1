function Import-GithubPRBuilderConfiguration() {
    $configuration = Import-Configuration -Name 'GithubPRBuilder' -CompanyName 'kosmonavtsv@gmail.com'
    
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
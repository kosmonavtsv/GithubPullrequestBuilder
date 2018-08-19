# Test for it **during** module import:
try {
    $null = Import-GithubPRBuilderConfiguration
}
catch {
    # Hide the error on import, just warn them
    Write-Warning "You must configure module to avoid this warning on first run. Use Set-GithubPRBuilderConfiguration"
}
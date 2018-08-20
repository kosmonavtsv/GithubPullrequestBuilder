Register-ArgumentCompleter -CommandName New-GithubPullrequest -ParameterName Base -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)

    $branches = git branch --no-color `
        | ? {$_ -notmatch "^\* \(HEAD detached .+\)$"}`
        | ? {$_ -match "^\*?\s*(?<ref>.*)"}`
        | % {$matches['ref'] }
    $branches += git branch --no-color -r `
        | ? {$_ -match "^  (?<ref>\S+)(?: -> .+)?"}`
        | % { $matches['ref'] }

    $branches `
        | ? { $_ -ne '(no branch)'}`
        | ? { $_ -like "$wordToComplete*" } `
        | % { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)}
}


# Test for it **during** module import:
try {
    $null = Import-GithubPRBuilderConfiguration
}
catch {
    # Hide the error on import, just warn them
    Write-Warning "You must configure module to avoid this warning on first run. Use Set-GithubPRBuilderConfiguration"
}
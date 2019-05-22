function Get-ModulePRTemplate {
    [CmdletBinding()]
    [OutputType([string])]

    $config = Import-GithubPRBuilderConfiguration
    if ($config.$PRTemplatePath) {
        Get-Content $confog.$PRTemplatePath -Raw
    }
    else {
        $PRTemplate
    }
}

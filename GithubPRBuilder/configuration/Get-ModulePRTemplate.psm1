function Get-ModulePRTemplate {
    [CmdletBinding()]
    [OutputType([string])]

    $config = Import-GithubPRBuilderConfiguration
    if ($config.$PRTemplatePath) {
        Get-Content $config.$PRTemplatePath -Raw
    }
    else {
        $PRTemplate
    }
}

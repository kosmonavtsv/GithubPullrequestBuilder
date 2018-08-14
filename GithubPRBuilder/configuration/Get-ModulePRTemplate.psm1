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
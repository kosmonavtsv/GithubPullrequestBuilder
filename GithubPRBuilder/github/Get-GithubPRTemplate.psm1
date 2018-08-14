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
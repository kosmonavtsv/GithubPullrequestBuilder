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
        [AllowEmptyString()]
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

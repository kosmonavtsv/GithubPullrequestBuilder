function New-JiraAuthHeader {
    $settings = Import-GithubPRBuilderConfiguration
    $bytes = [System.Text.Encoding]::ASCII.GetBytes("$($settings.JiraLogin):$($settings.JiraPassword)")
    $encodedCreds = 'Basic ' + [System.Convert]::ToBase64String($bytes)
    @{Authorization = $encodedCreds}
}

# Line break for readability in AppVeyor console
Write-Output ''

# Make sure we're using the Master branch and that it's not a pull request
# Environmental Variables Guide: https://www.appveyor.com/docs/environment-variables/
if ($env:APPVEYOR_REPO_BRANCH -ne 'master' -and
    $env:APPVEYOR_REPO_BRANCH -notmatch 'version') {
    Write-Warning -Message "Skipping version increment and publish for branch $env:APPVEYOR_REPO_BRANCH"
}
elseif ($env:APPVEYOR_PULL_REQUEST_NUMBER -gt 0) {
    Write-Warning -Message "Skipping version increment and publish for pull request #$env:APPVEYOR_PULL_REQUEST_NUMBER"
}
else {
    $env:Path += ";$env:ProgramFiles\Git\cmd"
    $manifestPath = '.\GithubPRBuilder\GithubPRBuilder.psd1'

    .\build\Update-Manifest.ps1 -ManifestPath $manifestPath -BuildNumber  $env:APPVEYOR_BUILD_NUMBER
    .\build\Publish-ToPowerShellGallery.ps1 -NuGetApiKey $env:NuGetApiKey
    $moduleVersion = .\build\Get-ModuleVersion.ps1 -ManifestPath $manifestPath
    .\build\Publish-ToGit.ps1 -Branch $env:APPVEYOR_REPO_BRANCH -ModuleVersion $moduleVersion
}

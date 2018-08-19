$ProjectRoot = Split-Path -Path $PSScriptRoot -Parent

$ModuleRoot = Join-Path -Path $ProjectRoot -ChildPath "GithubPRBuilder"
$ManifestFile = Join-Path -Path $ModuleRoot -ChildPath "GithubPRBuilder.psd1"

$ArtifactRoot = Join-Path -Path $ProjectRoot -ChildPath "dist"
$ArtifactModuleRoot = Join-Path -Path $ArtifactRoot -ChildPath "GithubPRBuilder"

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
    Push-Location
    Set-Location $ProjectRoot

    .\build\Update-Manifest.ps1 -ManifestPath $ManifestFile -BuildNumber  $env:APPVEYOR_BUILD_NUMBER
    .\build\Publish-ModuleArtifacts -ModuleRoot $ModuleRoot -ArtifactRoot $ArtifactRoot
    .\build\Publish-ToPowerShellGallery.ps1 -ModuleRoot $ArtifactModuleRoot -NuGetApiKey $env:NuGetApiKey

    Pop-Location
}

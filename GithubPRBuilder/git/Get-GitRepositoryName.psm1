function Get-GitRepositoryName {
    $originUrls = (git config --get remote.origin.url)
    $repository = $originUrls `
        | ? {$_ -match ':[^/]*?/(?<rep>.*?)\.git'} `
        | % {$Matches['rep']} `
        | select -First 1
    return $repository
}
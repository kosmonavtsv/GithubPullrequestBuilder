function Get-GitLog {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Base,
        [Parameter(Mandatory)]
        [string]$LogFormat
    )
    if ($Script:gitCommitsCache) {
        $log = $Script:gitCommitsCache
    }
    else {
        Write-Verbose "git fetch origin $Base"
        $null = (git fetch origin $Base)
        Write-Verbose "git log $Target --not $Base --quiet --pretty=$LogFormat  --reverse"
        $log = (git log $Target --not $Base --quiet --pretty=$LogFormat  --reverse) -join "`r`n"
        # Encoding
        $utf8 = [System.Text.Encoding]::UTF8
        $outputEncoding = [Console]::OutputEncoding
        $log = $utf8.GetString($outputEncoding.GetBytes($log))
        Write-Verbose "GIT COMMITS: $log"
        $Script:gitCommitsCache = $log
    }
    return $log
}

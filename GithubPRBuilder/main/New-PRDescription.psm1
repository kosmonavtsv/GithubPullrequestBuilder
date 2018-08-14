function New-PRDescription {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string]$Target,
        [Parameter(Mandatory)]
        [string]$Base
    )
    $prTemplate = Get-ModulePRTemplate
    $prTemplate = Fill-JiraParagraph -Template $prTemplate -Target $Target -Base $Base
    $prTemplate = Fill-SolutionParagraph -Template $prTemplate -Target $Target -Base $Base
    Write-Verbose "PR Description:`r`n$prTemplate"
    $prTemplate
}
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$templatesRoot = Join-Path $repoRoot 'templates'
$manifestPath = Join-Path $repoRoot 'manifest.json'
$deploymentReadmePath = Join-Path $repoRoot 'deployment\README.md'
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputPath)

if (Test-Path -LiteralPath $resolvedOutput) {
    throw "Output path already exists: $resolvedOutput"
}

& (Join-Path $PSScriptRoot 'validate-templates.ps1')

$runtimeFiles = @(
    Get-ChildItem -LiteralPath $templatesRoot -Recurse -File |
        Where-Object { $_.Extension -in '.kvp', '.json', '.sh' }
)

$duplicateNames = @(
    $runtimeFiles |
        Group-Object Name |
        Where-Object Count -gt 1
)
if ($duplicateNames.Count -gt 0) {
    $names = ($duplicateNames.Name | Sort-Object) -join ', '
    throw "Template files cannot be flattened because names collide: $names"
}

$null = New-Item -ItemType Directory -Path $resolvedOutput
Copy-Item -LiteralPath $manifestPath -Destination $resolvedOutput
Copy-Item -LiteralPath $deploymentReadmePath `
    -Destination (Join-Path $resolvedOutput 'README.md')

foreach ($runtimeFile in $runtimeFiles) {
    Copy-Item -LiteralPath $runtimeFile.FullName -Destination $resolvedOutput
}

$artifactFiles = @(
    Get-ChildItem -LiteralPath $resolvedOutput -File |
        Sort-Object Name
)

Write-Output "Built flat AMP artifact with $($artifactFiles.Count) files:"
$artifactFiles | ForEach-Object { Write-Output "  $($_.Name)" }

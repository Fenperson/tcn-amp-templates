[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$repoManifestPath = Join-Path $repoRoot 'manifest.json'

if (-not (Test-Path -LiteralPath $repoManifestPath -PathType Leaf)) {
    throw 'Repository root is missing required AMP manifest.json.'
}

$repoManifest = Get-Content -LiteralPath $repoManifestPath -Raw |
    ConvertFrom-Json -Depth 20

foreach ($requiredProperty in @(
    'id',
    'authors',
    'origin',
    'url',
    'imagefile',
    'prefix',
    'repotype'
)) {
    if ($requiredProperty -notin $repoManifest.PSObject.Properties.Name) {
        throw "manifest.json: missing required property $requiredProperty"
    }
}

$repoId = [guid]::Empty
if (-not [guid]::TryParse($repoManifest.id, [ref]$repoId) -or
    $repoId -eq [guid]::Empty) {
    throw 'manifest.json: id must be a non-empty GUID.'
}

if ($repoManifest.authors.Count -lt 1 -or
    @($repoManifest.authors |
        Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
    throw 'manifest.json: authors must contain at least one non-empty name.'
}

if ($repoManifest.origin -ne
    'https://github.com/Fenperson/tcn-amp-templates.git') {
    throw 'manifest.json: origin must identify the canonical Git repository.'
}
if ($repoManifest.url -ne
    'https://github.com/Fenperson/tcn-amp-templates') {
    throw 'manifest.json: url must identify the public repository page.'
}
if ($repoManifest.repotype -ne 'AppTemplates') {
    throw 'manifest.json: repotype must be AppTemplates.'
}

$templateFiles = Get-ChildItem -LiteralPath $repoRoot -Filter '*.kvp' -File |
    Sort-Object Name

if ($templateFiles.Count -eq 0) {
    throw 'No template KVP files were found at repository root.'
}

$seenAppIds = @{}
$seenConfigRoots = @{}

foreach ($templateFile in $templateFiles) {
    $settings = @{}

    foreach ($line in Get-Content -LiteralPath $templateFile.FullName) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) {
            continue
        }

        $separator = $line.IndexOf('=')
        if ($separator -lt 1) {
            throw "$($templateFile.Name): invalid KVP line: $line"
        }

        $key = $line.Substring(0, $separator)
        $value = $line.Substring($separator + 1)
        $settings[$key] = $value
    }

    $requiredKeys = @(
        'Meta.DisplayName',
        'Meta.ConfigManifest',
        'Meta.MetaConfigManifest',
        'Meta.ConfigRoot',
        'Meta.ConfigVersion',
        'Meta.AppConfigId',
        'App.BaseDirectory',
        'App.ExecutableLinux',
        'App.WorkingDir'
    )

    foreach ($requiredKey in $requiredKeys) {
        if (-not $settings.ContainsKey($requiredKey) -or
            [string]::IsNullOrWhiteSpace($settings[$requiredKey])) {
            throw "$($templateFile.Name): missing required key $requiredKey"
        }
    }

    $version = 0
    if (-not [int]::TryParse($settings['Meta.ConfigVersion'], [ref]$version) -or
        $version -lt 1) {
        throw "$($templateFile.Name): Meta.ConfigVersion must be a positive integer."
    }

    $appId = [guid]::Empty
    if (-not [guid]::TryParse($settings['Meta.AppConfigId'], [ref]$appId)) {
        throw "$($templateFile.Name): Meta.AppConfigId must be a GUID."
    }

    $appIdKey = $appId.ToString()
    if ($seenAppIds.ContainsKey($appIdKey)) {
        throw "$($templateFile.Name): Meta.AppConfigId duplicates $($seenAppIds[$appIdKey])."
    }
    $seenAppIds[$appIdKey] = $templateFile.Name

    $configRoot = $settings['Meta.ConfigRoot']
    if ($configRoot -ne $templateFile.Name) {
        throw "$($templateFile.Name): Meta.ConfigRoot must equal the template filename."
    }
    if ($seenConfigRoots.ContainsKey($configRoot)) {
        throw "$($templateFile.Name): duplicate Meta.ConfigRoot $configRoot."
    }
    $seenConfigRoots[$configRoot] = $templateFile.Name

    foreach ($manifestKey in @('Meta.ConfigManifest', 'Meta.MetaConfigManifest')) {
        $referencedName = $settings[$manifestKey]
        $referencedPath = Join-Path $repoRoot $referencedName
        if (-not (Test-Path -LiteralPath $referencedPath -PathType Leaf)) {
            throw "$($templateFile.Name): $manifestKey references missing file $referencedName"
        }

        $null = Get-Content -LiteralPath $referencedPath -Raw |
            ConvertFrom-Json -Depth 100
    }

    if ($settings.ContainsKey('Meta.UpdateManifest') -and
        -not [string]::IsNullOrWhiteSpace($settings['Meta.UpdateManifest'])) {
        $updatePath = Join-Path $repoRoot $settings['Meta.UpdateManifest']
        if (-not (Test-Path -LiteralPath $updatePath -PathType Leaf)) {
            throw "$($templateFile.Name): Meta.UpdateManifest references a missing file."
        }
        $null = Get-Content -LiteralPath $updatePath -Raw |
            ConvertFrom-Json -Depth 100
    }
}

$sensitivePattern = '(?i)(password|passwd|token|secret|api[_-]?key)\s*[:=]\s*["'']?[^\s"'']+'
$sourceFiles = Get-ChildItem -LiteralPath $repoRoot -File |
    Where-Object { $_.Extension -in '.kvp', '.json', '.sh' }

foreach ($sourceFile in $sourceFiles) {
    $matches = Select-String -LiteralPath $sourceFile.FullName -Pattern $sensitivePattern
    foreach ($match in $matches) {
        $line = $match.Line
        if ($line -match '(?i)(RemoteAdminPassword|GamePassword)=\s*$' -or
            $line -match '(?i)"DefaultValue"\s*:\s*""' -or
            $line -match '(?i)(password|token|secret|api[_-]?key)\s*[:=]\s*(true|false|none|0)\s*[,}]?$' -or
            $line -match '\{\{[^}]+\}\}') {
            continue
        }
        throw "$($sourceFile.Name): possible embedded secret on line $($match.LineNumber)."
    }
}

Write-Output "Validated AMP repository manifest and $($templateFiles.Count) templates."

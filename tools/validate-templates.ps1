[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$templatesRoot = Join-Path $repoRoot 'templates'
$repoManifestPath = Join-Path $repoRoot 'manifest.json'

function Read-KvpFile {
    param(
        [Parameter(Mandatory)]
        [System.IO.FileInfo] $File
    )

    $settings = @{}

    foreach ($line in Get-Content -LiteralPath $File.FullName) {
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) {
            continue
        }

        $separator = $line.IndexOf('=')
        if ($separator -lt 1) {
            throw "$($File.FullName): invalid KVP line: $line"
        }

        $key = $line.Substring(0, $separator)
        $value = $line.Substring($separator + 1)
        $settings[$key] = $value
    }

    return $settings
}

function Test-RepositoryManifest {
    if (-not (Test-Path -LiteralPath $repoManifestPath -PathType Leaf)) {
        throw 'Repository root is missing required manifest.json.'
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
}

function Test-TemplateSet {
    param(
        [Parameter(Mandatory)]
        [System.IO.FileInfo[]] $TemplateFiles
    )

    $seenAppIds = @{}
    $seenConfigRoots = @{}

    foreach ($templateFile in $TemplateFiles) {
        $settings = Read-KvpFile -File $templateFile
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
                throw "$($templateFile.FullName): missing required key $requiredKey"
            }
        }

        $version = 0
        if (-not [int]::TryParse(
            $settings['Meta.ConfigVersion'],
            [ref]$version
        ) -or $version -lt 1) {
            throw "$($templateFile.FullName): Meta.ConfigVersion must be positive."
        }

        $appId = [guid]::Empty
        if (-not [guid]::TryParse(
            $settings['Meta.AppConfigId'],
            [ref]$appId
        )) {
            throw "$($templateFile.FullName): Meta.AppConfigId must be a GUID."
        }

        $appIdKey = $appId.ToString()
        if ($seenAppIds.ContainsKey($appIdKey)) {
            throw "$($templateFile.FullName): Meta.AppConfigId duplicates $($seenAppIds[$appIdKey])."
        }
        $seenAppIds[$appIdKey] = $templateFile.FullName

        $configRoot = $settings['Meta.ConfigRoot']
        if ($configRoot -ne $templateFile.Name) {
            throw "$($templateFile.FullName): Meta.ConfigRoot must equal the template filename."
        }
        if ($seenConfigRoots.ContainsKey($configRoot)) {
            throw "$($templateFile.FullName): duplicate Meta.ConfigRoot $configRoot."
        }
        $seenConfigRoots[$configRoot] = $templateFile.FullName

        foreach ($manifestKey in @(
            'Meta.ConfigManifest',
            'Meta.MetaConfigManifest'
        )) {
            $referencedName = $settings[$manifestKey]
            $referencedPath = Join-Path $templateFile.DirectoryName $referencedName
            if (-not (Test-Path -LiteralPath $referencedPath -PathType Leaf)) {
                throw "$($templateFile.FullName): $manifestKey references missing file $referencedName"
            }

            $null = Get-Content -LiteralPath $referencedPath -Raw |
                ConvertFrom-Json -Depth 100
        }

        if ($settings.ContainsKey('Meta.UpdateManifest') -and
            -not [string]::IsNullOrWhiteSpace(
                $settings['Meta.UpdateManifest']
            )) {
            $updatePath = Join-Path `
                $templateFile.DirectoryName `
                $settings['Meta.UpdateManifest']
            if (-not (Test-Path -LiteralPath $updatePath -PathType Leaf)) {
                throw "$($templateFile.FullName): Meta.UpdateManifest references a missing file."
            }
            $null = Get-Content -LiteralPath $updatePath -Raw |
                ConvertFrom-Json -Depth 100
        }
    }
}

Test-RepositoryManifest

if (-not (Test-Path -LiteralPath $templatesRoot -PathType Container)) {
    throw 'Canonical templates directory is missing.'
}

$templateDirectories = @(
    Get-ChildItem -LiteralPath $templatesRoot -Directory |
        Sort-Object Name
)
if ($templateDirectories.Count -eq 0) {
    throw 'No canonical template directories were found.'
}

$templateFiles = @()
foreach ($templateDirectory in $templateDirectories) {
    $directoryTemplates = @(
        Get-ChildItem -LiteralPath $templateDirectory.FullName `
            -Filter '*.kvp' `
            -File
    )
    if ($directoryTemplates.Count -ne 1) {
        throw "$($templateDirectory.FullName): expected exactly one KVP file."
    }
    if ($directoryTemplates[0].BaseName -ne $templateDirectory.Name) {
        throw "$($templateDirectory.FullName): directory and KVP names must match."
    }
    $templateFiles += $directoryTemplates[0]
}

$unexpectedRootRuntimeFiles = @(
    Get-ChildItem -LiteralPath $repoRoot -File |
        Where-Object {
            $_.Extension -in '.kvp', '.sh' -or
            ($_.Extension -eq '.json' -and $_.Name -ne 'manifest.json')
        }
)
if ($unexpectedRootRuntimeFiles.Count -gt 0) {
    $names = ($unexpectedRootRuntimeFiles.Name | Sort-Object) -join ', '
    throw "Deployable template files belong under templates/: $names"
}

Test-TemplateSet -TemplateFiles $templateFiles

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

$sensitivePattern = '(?i)(password|passwd|token|secret|api[_-]?key)\s*[:=]\s*["'']?[^\s"'']+'
foreach ($sourceFile in $runtimeFiles) {
    $matches = Select-String `
        -LiteralPath $sourceFile.FullName `
        -Pattern $sensitivePattern
    foreach ($match in $matches) {
        $line = $match.Line
        if ($line -match '(?i)(RemoteAdminPassword|GamePassword)=\s*$' -or
            $line -match '(?i)"DefaultValue"\s*:\s*""' -or
            $line -match '(?i)(password|token|secret|api[_-]?key)\s*[:=]\s*(true|false|none|0)\s*[,}]?$' -or
            $line -match '\{\{[^}]+\}\}') {
            continue
        }
        throw "$($sourceFile.FullName): possible embedded secret on line $($match.LineNumber)."
    }
}

$temporaryBase = [System.IO.Path]::GetFullPath(
    [System.IO.Path]::GetTempPath()
)
$temporaryArtifact = Join-Path `
    $temporaryBase `
    "tcn-amp-artifact-validation-$([guid]::NewGuid())"

try {
    $null = New-Item -ItemType Directory -Path $temporaryArtifact
    Copy-Item -LiteralPath $repoManifestPath -Destination $temporaryArtifact
    foreach ($runtimeFile in $runtimeFiles) {
        Copy-Item -LiteralPath $runtimeFile.FullName -Destination $temporaryArtifact
    }

    $flatTemplateFiles = @(
        Get-ChildItem -LiteralPath $temporaryArtifact `
            -Filter '*.kvp' `
            -File |
            Sort-Object Name
    )
    Test-TemplateSet -TemplateFiles $flatTemplateFiles
}
finally {
    $resolvedTemporaryArtifact = [System.IO.Path]::GetFullPath(
        $temporaryArtifact
    )
    if ($resolvedTemporaryArtifact.StartsWith(
        $temporaryBase,
        [System.StringComparison]::OrdinalIgnoreCase
    ) -and (Test-Path -LiteralPath $resolvedTemporaryArtifact)) {
        Remove-Item -LiteralPath $resolvedTemporaryArtifact -Recurse -Force
    }
}

Write-Output (
    "Validated $($templateDirectories.Count) canonical template directories " +
    'and their flat AMP artifact.'
)

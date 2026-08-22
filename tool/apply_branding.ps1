param(
    [switch]$SkipIconGeneration
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$brandingPath = Join-Path $root "lib/core/constants/app_branding.dart"
$androidStringsPath = Join-Path $root "android/app/src/main/res/values/strings.xml"
$iosInfoPlistPath = Join-Path $root "ios/Runner/Info.plist"
$pubspecPath = Join-Path $root "pubspec.yaml"

function Read-DartStringConstant {
    param(
        [Parameter(Mandatory = $true)][string]$Content,
        [Parameter(Mandatory = $true)][string]$Name
    )

    $pattern = "static\s+const\s+String\s+$Name\s*=\s*'([^']+)';"
    $match = [regex]::Match($Content, $pattern)
    if (-not $match.Success) {
        throw "Could not find AppBranding.$Name in $brandingPath"
    }

    return $match.Groups[1].Value
}

if (-not (Test-Path -LiteralPath $brandingPath)) {
    throw "Branding file not found: $brandingPath"
}

$brandingContent = Get-Content -LiteralPath $brandingPath -Raw
$appName = Read-DartStringConstant -Content $brandingContent -Name "appName"
$launcherIconPath = Read-DartStringConstant -Content $brandingContent -Name "launcherIconPath"
$launcherIconFullPath = Join-Path $root $launcherIconPath

if (-not (Test-Path -LiteralPath $launcherIconFullPath)) {
    throw "Launcher icon not found: $launcherIconFullPath"
}

Write-Host "Applying branding:"
Write-Host "  App name: $appName"
Write-Host "  Launcher icon: $launcherIconPath"

$androidValuesDir = Split-Path -Parent $androidStringsPath
if (-not (Test-Path -LiteralPath $androidValuesDir)) {
    New-Item -ItemType Directory -Path $androidValuesDir | Out-Null
}

$androidXml = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$appName</string>
</resources>
"@
Set-Content -LiteralPath $androidStringsPath -Value $androidXml -Encoding utf8

$plistContent = Get-Content -LiteralPath $iosInfoPlistPath -Raw
$plistContent = [regex]::Replace(
    $plistContent,
    "(<key>CFBundleDisplayName</key>\s*<string>)(.*?)(</string>)",
    "`${1}$appName`${3}",
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)
$plistContent = [regex]::Replace(
    $plistContent,
    "(<key>CFBundleName</key>\s*<string>)(.*?)(</string>)",
    "`${1}$appName`${3}",
    [System.Text.RegularExpressions.RegexOptions]::Singleline
)
Set-Content -LiteralPath $iosInfoPlistPath -Value $plistContent -Encoding utf8

$pubspecContent = Get-Content -LiteralPath $pubspecPath -Raw
$pubspecContent = [regex]::Replace(
    $pubspecContent,
    "(?m)^(\s*image_path:\s*).*$",
    "`${1}$launcherIconPath"
)
Set-Content -LiteralPath $pubspecPath -Value $pubspecContent -Encoding utf8

if (-not $SkipIconGeneration) {
    Push-Location $root
    try {
        flutter pub get
        dart run flutter_launcher_icons
    } finally {
        Pop-Location
    }
} else {
    Write-Host "Skipped launcher icon generation."
}

Write-Host "Branding applied successfully."

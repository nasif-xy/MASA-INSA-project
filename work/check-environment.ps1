$ErrorActionPreference = "Continue"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot
$script:NeedsAttention = $false

function Test-CommandPath([string]$Label, [string]$CommandName) {
    $Found = Get-Command $CommandName -ErrorAction SilentlyContinue
    if ($Found) { Write-Host ("OK   {0,-14} {1}" -f $Label, $Found.Source) }
    else { Write-Host ("MISS {0,-14} command: {1}" -f $Label, $CommandName); $script:NeedsAttention = $true }
}
function Test-ToolFile([string]$Label, [string]$Path) {
    if ($Path -and (Test-Path -LiteralPath $Path -PathType Leaf)) { Write-Host ("OK   {0,-14} {1}" -f $Label, $Path) }
    else { Write-Host ("MISS {0,-14} {1}" -f $Label, $Path); $script:NeedsAttention = $true }
}
function Get-DotEnvValue([string]$Name) {
    $EnvFile = Join-Path $ProjectRoot ".env"
    if (-not (Test-Path $EnvFile)) { return $null }
    foreach ($Line in Get-Content $EnvFile) {
        if ($Line -match "^\s*$([regex]::Escape($Name))\s*=\s*(.*?)\s*$") {
            return $Matches[1].Trim().Trim('"').Trim("'")
        }
    }
    return $null
}

Test-CommandPath "Python" "python"
Test-CommandPath "Node.js" "node"
Test-CommandPath "npm" "npm"
Test-CommandPath "Java" "java"
Test-CommandPath "ADB" "adb"

$Apktool = if ($env:MOBILE_PENTEST_APKTOOL_JAR_PATH) { $env:MOBILE_PENTEST_APKTOOL_JAR_PATH } else { Get-DotEnvValue "MOBILE_PENTEST_APKTOOL_JAR_PATH" }
if (-not $Apktool) { $Apktool = "C:\tools\apktool.jar" }
$Jadx = if ($env:MOBILE_PENTEST_JADX_JAR_PATH) { $env:MOBILE_PENTEST_JADX_JAR_PATH } else { Get-DotEnvValue "MOBILE_PENTEST_JADX_JAR_PATH" }
if (-not $Jadx) {
    $Candidates = @(
        (Join-Path $HOME ".local\opt\jadx\lib\jadx-1.5.2-all.jar"),
        (Join-Path $HOME ".local\share\masa\jadx-cli-all.jar"),
        "C:\tools\jadx\lib\jadx-cli-all.jar"
    )
    $Jadx = $Candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if (-not $Jadx) { $Jadx = $Candidates[0] }
}
Test-ToolFile "apktool JAR" $Apktool
Test-ToolFile "JADX JAR" $Jadx

if (Test-Path (Join-Path $ProjectRoot "frontend\package.json")) {
    Write-Host "OK   frontend       frontend/package.json"
} else {
    Write-Host "MISS frontend       frontend/package.json"
    $script:NeedsAttention = $true
}
if (Get-Command pg_isready -ErrorAction SilentlyContinue) {
    & pg_isready -q
    if ($LASTEXITCODE -eq 0) { Write-Host "OK   PostgreSQL     accepting connections" }
    else { Write-Host "INFO PostgreSQL     unavailable; SQLite fallback supported" }
} else {
    Write-Host "INFO PostgreSQL     pg_isready not installed; SQLite fallback supported"
}

if ($script:NeedsAttention) {
    Write-Host ""
    Write-Host "Environment needs attention before a full scan."
    exit 1
}
Write-Host ""
Write-Host "Core commands are available. Verify APK tools and Android SDK paths before full analysis."
exit 0

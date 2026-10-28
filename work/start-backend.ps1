$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot
$env:PYTHONPATH = ".;backend"

function Get-DotEnvValue([string]$Name) {
    $EnvFile = Join-Path $ProjectRoot ".env"
    if (-not (Test-Path $EnvFile)) { return $null }
    foreach ($Line in Get-Content $EnvFile) {
        if ($Line -match "^\s*$([regex]::Escape($Name))\s*=\s*(.*?)\s*$") {
            $Value = $Matches[1].Trim()
            if (($Value.StartsWith('"') -and $Value.EndsWith('"')) -or ($Value.StartsWith("'") -and $Value.EndsWith("'"))) {
                $Value = $Value.Substring(1, $Value.Length - 2)
            }
            return $Value
        }
    }
    return $null
}

$ExplicitDatabaseUrl = $env:MOBILE_PENTEST_DATABASE_URL
if ([string]::IsNullOrWhiteSpace($ExplicitDatabaseUrl)) {
    $ExplicitDatabaseUrl = Get-DotEnvValue "MOBILE_PENTEST_DATABASE_URL"
}
if (-not [string]::IsNullOrWhiteSpace($ExplicitDatabaseUrl)) {
    Write-Host "Using the explicitly configured database URL."
} elseif (Get-Command pg_isready -ErrorAction SilentlyContinue) {
    $PgHost = if ($env:MOBILE_PENTEST_POSTGRES_HOST) { $env:MOBILE_PENTEST_POSTGRES_HOST } else { "localhost" }
    $PgPort = if ($env:MOBILE_PENTEST_POSTGRES_PORT) { $env:MOBILE_PENTEST_POSTGRES_PORT } else { "5432" }
    $PgDb = if ($env:MOBILE_PENTEST_POSTGRES_DB) { $env:MOBILE_PENTEST_POSTGRES_DB } else { "MASA_DB" }
    $PgUser = if ($env:MOBILE_PENTEST_POSTGRES_USER) { $env:MOBILE_PENTEST_POSTGRES_USER } else { "postgres" }
    & pg_isready -q -h $PgHost -p $PgPort -d $PgDb -U $PgUser
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Using PostgreSQL at the configured host."
    } else {
        Write-Host "PostgreSQL unavailable; using local SQLite."
        $env:MOBILE_PENTEST_DATABASE_URL = "sqlite:///./storage/masa.sqlite3"
    }
} else {
    Write-Host "pg_isready not found; using local SQLite unless .env specifies a database."
    $env:MOBILE_PENTEST_DATABASE_URL = "sqlite:///./storage/masa.sqlite3"
}

$Python = Join-Path $ProjectRoot "myenv\Scripts\python.exe"
if (-not (Test-Path $Python)) { $Python = Join-Path $ProjectRoot ".venv\Scripts\python.exe" }
if (-not (Test-Path $Python)) { $Python = (Get-Command python -ErrorAction Stop).Source }

Write-Host "Starting MASA backend at http://127.0.0.1:8000"
& $Python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
exit $LASTEXITCODE

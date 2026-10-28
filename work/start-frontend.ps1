$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$FrontendPath = Join-Path $ProjectRoot "frontend"
if (-not (Test-Path (Join-Path $FrontendPath "package.json"))) {
    throw "Could not find frontend/package.json."
}
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "npm was not found. Install Node.js LTS, reopen PowerShell, and retry."
}
Set-Location $FrontendPath
npm run dev
exit $LASTEXITCODE

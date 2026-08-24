[CmdletBinding()]
param(
    [int]$Port = 8000,
    [string]$AllowedHost = "localhost:$Port"
)

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$scrapling = Join-Path $projectRoot ".venv\Scripts\scrapling-mcp.exe"
$runtimeDir = Join-Path $projectRoot ".runtime"
$tokenFile = Join-Path $runtimeDir "scrapling-mcp.token"

if (-not (Test-Path -LiteralPath $scrapling)) {
    throw "Scrapling MCP executable tidak ditemukan: $scrapling"
}

New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
if (-not (Test-Path -LiteralPath $tokenFile)) {
    $bytes = New-Object byte[] 32
    [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    [Convert]::ToBase64String($bytes) | Set-Content -LiteralPath $tokenFile -NoNewline
}

$token = (Get-Content -LiteralPath $tokenFile -Raw).Trim()
if ([string]::IsNullOrWhiteSpace($token)) {
    throw "Token lokal kosong: $tokenFile"
}

$env:SCRAPLING_MCP_AUTH_TOKEN = $token
Write-Host "Scrapling MCP HTTP listening on http://127.0.0.1:$Port"
Write-Host "Token stored in ignored local file: $tokenFile"
Write-Host "Development only; use the authenticated launcher and secret manager for deployment."

& $scrapling --http --host 127.0.0.1 --port $Port --allowed-host $AllowedHost
exit $LASTEXITCODE

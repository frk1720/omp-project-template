[CmdletBinding()]
param(
    [int]$Port = 8000,
    [string]$AllowedHost = "localhost:$Port"
)

$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$scrapling = Join-Path $projectRoot ".venv\Scripts\scrapling-mcp.exe"

if (-not (Test-Path -LiteralPath $scrapling)) {
    throw "Scrapling MCP executable tidak ditemukan: $scrapling"
}

$token = [Environment]::GetEnvironmentVariable("SCRAPLING_MCP_AUTH_TOKEN", "Process")
if ([string]::IsNullOrWhiteSpace($token)) {
    throw "SCRAPLING_MCP_AUTH_TOKEN wajib di-set pada process environment. Jangan menaruh token di file atau command line."
}

$env:SCRAPLING_MCP_AUTH_TOKEN = $token
& $scrapling --http --host 127.0.0.1 --port $Port --allowed-host $AllowedHost
exit $LASTEXITCODE

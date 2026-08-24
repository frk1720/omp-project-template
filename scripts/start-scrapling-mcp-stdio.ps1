[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$scrapling = Join-Path $projectRoot ".venv\Scripts\scrapling-mcp.exe"

if (-not (Test-Path -LiteralPath $scrapling)) {
    throw "Scrapling MCP executable tidak ditemukan: $scrapling"
}

& $scrapling
exit $LASTEXITCODE

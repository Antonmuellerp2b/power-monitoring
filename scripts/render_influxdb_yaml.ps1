# render_influxdb_yaml.ps1 - Render InfluxDB datasource config from template using .env variables.
# Usage: ./scripts/render_influxdb_yaml.ps1

$ErrorActionPreference = "Stop"

# Script- und Projekt-Pfade
$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path $scriptDir -Parent

# Pfade
$envPath     = Join-Path $projectRoot ".env"
$templatePath = Join-Path $projectRoot "templates/influxdb.yaml.template"
$outputPath   = Join-Path $projectRoot "grafana/provisioning/datasources/influxdb.yaml"
$outputDir    = Split-Path $outputPath -Parent

# Load .env variables
if (Test-Path $envPath) {
    Get-Content $envPath | ForEach-Object {
        if ($_ -match '^\s*([^#][^=]+?)=(.*)') {
            $name  = $matches[1].Trim()
            $value = $matches[2].Trim().Trim("'`"")
            [System.Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
} else {
    Write-Error ".env file not found at $envPath"
    exit 1
}

# Template-Verzeichnis erstellen
New-Item -ItemType Directory -Force -Path $outputDir | Out-Null

# Load template, skip comment lines
$templateLines = Get-Content $templatePath | Where-Object { $_ -notmatch '^\s*#' }
$template = ($templateLines -join "`n")

# Replace ${VARNAME} or $VARNAME with environment variable values
$templateReplaced = [regex]::Replace($template, '\$\{?(\w+)\}?', {
    param($match)
    $varName = $match.Groups[1].Value
    $returnVal = [System.Environment]::GetEnvironmentVariable($varName, "Process")
    if ([string]::IsNullOrEmpty($returnVal)) { return "" }
    else { return $returnVal }
})

$templateReplaced | Set-Content -Encoding UTF8 $outputPath
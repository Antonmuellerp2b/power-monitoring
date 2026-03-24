# render_contact_points_yaml.ps1 - Render Grafana contact-points.yaml from template using .env variables.
# Usage: ./scripts/render_contact_points_yaml.ps1

$ErrorActionPreference = "Stop"

# Get script directory and project root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path $scriptDir -Parent

# .env path
$envPath = Join-Path $projectRoot ".env"

# Load .env variables
if (Test-Path $envPath) {
    Get-Content $envPath | ForEach-Object {
        if ($_ -match '^([\w]+)=(.*)$') {
            $name = $matches[1]
            $value = $matches[2]
            [System.Environment]::SetEnvironmentVariable($name, $value)
        }
    }
} else {
    Write-Error ".env file not found at $envPath"
    exit 1
}

# Template and output paths
$template = Join-Path $projectRoot "templates/contact-points.yaml.template"
$output   = Join-Path $projectRoot "grafana/provisioning/alerting/contact-points.yaml"

$recipient = [System.Environment]::GetEnvironmentVariable("ALERT_EMAIL_RECIPIENT")
$siteId    = [System.Environment]::GetEnvironmentVariable("SITE_ID")

if (-not $recipient) {
    Write-Error "ALERT_EMAIL_RECIPIENT is not set in .env!"
    exit 1
}
if (-not $siteId) {
    Write-Error "SITE_ID is not set in .env!"
    exit 1
}

# Filter out comment lines starting with # and replace placeholders
(Get-Content $template | Where-Object { $_ -notmatch '^\s*#' }) `
    -replace "{{ALERT_EMAIL_RECIPIENT}}", $recipient `
    -replace "{{SITE_ID}}", $siteId `
    | Set-Content $output
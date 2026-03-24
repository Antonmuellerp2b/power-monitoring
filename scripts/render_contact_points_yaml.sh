#!/bin/bash
# render_contact_points_yaml.sh - Render Grafana contact-points.yaml from template using .env variables.
# Usage: ./scripts/render_contact_points_yaml.sh

set -eu

# Projekt-Root ermitteln (eine Ebene über /scripts)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Load .env variables from project root
ENV_FILE="$PROJECT_ROOT/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  . "$ENV_FILE"
  set +a
else
  echo ".env file not found at $ENV_FILE" >&2
  exit 1
fi

# Template und Output Pfade
TEMPLATE="$PROJECT_ROOT/templates/contact-points.yaml.template"
OUTPUT="$PROJECT_ROOT/grafana/provisioning/alerting/contact-points.yaml"

# Check required variables
: "${ALERT_EMAIL_RECIPIENT:?ALERT_EMAIL_RECIPIENT not set in .env!}"
: "${SITE_ID:?SITE_ID not set in .env!}"

# Render template, skip comment lines
grep -v '^#' "$TEMPLATE" | sed \
  -e "s/{{ALERT_EMAIL_RECIPIENT}}/$ALERT_EMAIL_RECIPIENT/g" \
  -e "s/{{SITE_ID}}/$SITE_ID/g" \
  > "$OUTPUT"
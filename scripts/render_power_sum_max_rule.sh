#!/bin/bash
# render_power_sum_max_rule.sh - Render Grafana power_sum_max_rule.yaml from template using .env variables.
# Usage: ./scripts/render_power_sum_max_rule.sh

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
TEMPLATE="$PROJECT_ROOT/templates/power_sum_max.yaml.template"
OUTPUT="$PROJECT_ROOT/grafana/provisioning/alerting/power_sum_max_rule.yaml"

# Check required variables
: "${DATASOURCE_UID:?DATASOURCE_UID not set in .env!}"
: "${INFLUXDB_BUCKET:?INFLUXDB_BUCKET not set in .env!}"
: "${TOTAL_POWER_THRESHOLD_KW:?TOTAL_POWER_THRESHOLD_KW not set in .env!}"

# Create output directory if it does not exist
mkdir -p "$(dirname "$OUTPUT")"

# Replace placeholders in template with environment variables, skip comment lines
grep -v '^#' "$TEMPLATE" | sed \
  -e "s|{{DATASOURCE_UID}}|$DATASOURCE_UID|g" \
  -e "s|{{INFLUXDB_BUCKET}}|$INFLUXDB_BUCKET|g" \
  -e "s|{{TOTAL_POWER_THRESHOLD_KW}}|$TOTAL_POWER_THRESHOLD_KW|g" \
  > "$OUTPUT"
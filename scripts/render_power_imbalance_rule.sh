#!/usr/bin/env bash
# render_power_imbalance_rule.sh - Render Grafana power_imbalance_rule.yaml from template using .env variables.
# Usage: ./scripts/render_power_imbalance_rule.sh

set -euo pipefail

# Projekt-Root ermitteln (eine Ebene höher als /scripts)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Pfade
ENV_FILE="$PROJECT_ROOT/.env"
TEMPLATE="$PROJECT_ROOT/templates/power_imbalance_rule.yaml.template"
OUTPUT="$PROJECT_ROOT/grafana/provisioning/alerting/power_imbalance_rule.yaml"

# Load .env variables
if [[ -f "$ENV_FILE" ]]; then
    set -a
    . "$ENV_FILE"
    set +a
else
    echo ".env file not found at $ENV_FILE" >&2
    exit 1
fi

# Check required variables
: "${PHASE_IMBALANCE_RATIO_THRESHOLD:?PHASE_IMBALANCE_RATIO_THRESHOLD not set in .env!}"
: "${PHASE_IMBALANCE_MIN_KW:?PHASE_IMBALANCE_MIN_KW not set in .env!}"
: "${DATASOURCE_UID:?DATASOURCE_UID not set in .env!}"
: "${INFLUXDB_BUCKET:?INFLUXDB_BUCKET not set in .env!}"

# Render template, skip comment lines
grep -v '^#' "$TEMPLATE" | sed \
    -e "s|{{PHASE_IMBALANCE_RATIO_THRESHOLD}}|$PHASE_IMBALANCE_RATIO_THRESHOLD|g" \
    -e "s|{{PHASE_IMBALANCE_MIN_KW}}|$PHASE_IMBALANCE_MIN_KW|g" \
    -e "s|{{DATASOURCE_UID}}|$DATASOURCE_UID|g" \
    -e "s|{{INFLUXDB_BUCKET}}|$INFLUXDB_BUCKET|g" \
    > "$OUTPUT"
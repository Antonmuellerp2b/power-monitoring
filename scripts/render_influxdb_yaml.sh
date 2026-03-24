#!/bin/bash
# render_influxdb_yaml.sh - Render InfluxDB datasource config from template using .env variables.
# Usage: ./scripts/render_influxdb_yaml.sh

set -eu

# Projekt-Root ermitteln (eine Ebene höher als /scripts)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Load .env from project root
if [ -f "$PROJECT_ROOT/.env" ]; then
  set -a
  . "$PROJECT_ROOT/.env"
  set +a
else
  echo ".env file not found in project root" >&2
  exit 1
fi

# Pfade
TEMPLATE="$PROJECT_ROOT/templates/influxdb.yaml.template"
OUTPUT="$PROJECT_ROOT/grafana/provisioning/datasources/influxdb.yaml"

# Output-Verzeichnis erstellen
mkdir -p "$(dirname "$OUTPUT")"

# Template rendern
grep -v '^#' "$TEMPLATE" | envsubst > "$OUTPUT"
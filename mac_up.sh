#!/bin/zsh
# mac_up.sh - Start all services for PAC2200 monitoring stack.
# Renders all needed config files and starts docker compose.
# Usage: ./mac_up.sh [docker-compose-args...]

set -eu

# Render influxdb.yaml from template using .env
./scripts/render_influxdb_yaml.sh

# Render contact-points.yaml from template using .env
./scripts/render_contact_points_yaml.sh

# Render power_imbalance_rule.yaml from template using .env
./scripts/render_power_imbalance_rule.sh

# Render power_sum_max_rule.yaml from template using .env
./scripts/render_power_sum_max_rule.sh

# Render telegraf.conf from template using .env
./scripts/render_telegraf.conf.template.sh

# Start docker compose with any arguments passed to this script
exec docker compose up "$@"
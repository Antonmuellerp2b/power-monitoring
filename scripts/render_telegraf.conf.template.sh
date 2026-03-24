#!/bin/bash
# render_telegraf.conf.template.sh
# creates telegraf.conf from the appropriate template based on METER_TYPE

# export all variables from .env
set -a
source .env
set +a

# Select template based on METER_TYPE
if [ "$METER_TYPE" = "PAC2200" ]; then
    TEMPLATE="templates/pac2200.conf.template"
elif [ "$METER_TYPE" = "Janitza" ]; then
    TEMPLATE="templates/janitza.conf.template"
else
    echo "Fehler: METER_TYPE in .env nicht gesetzt oder ungültig (erwartet: PAC2200 oder Janitza). Verwende Standard-Template."
    TEMPLATE="templates/telegraf.conf.template"  # Fallback, falls vorhanden
fi

# target file
TARGET="telegraf/telegraf.conf"

# replace placeholders in template with environment variables
mkdir -p "$(dirname "$TARGET")"
envsubst < "$TEMPLATE" > "$TARGET"

echo "telegraf.conf generated from $TEMPLATE (METER_TYPE: $METER_TYPE)"
#!/bin/bash

MAUTIC="https://engage.yourdomain.com"
USER="user"
PASS="pass"

# Use the SEGMENT ALIAS, not the segment name
SEGMENT="segment-alias"

START=0
OUT="contacts-${SEGMENT}.csv"

echo '"id","firstname","lastname","email","phone","company"' > "$OUT"

while true; do
    JSON=$(curl -fsS \
        -u "${USER}:${PASS}" \
        --get "${MAUTIC}/api/contacts" \
        --data-urlencode "search=segment:${SEGMENT}" \
        --data-urlencode "start=${START}")

    COUNT=$(echo "$JSON" | jq '.contacts | length')
    TOTAL=$(echo "$JSON" | jq -r '.total | tonumber')

    if [ "$COUNT" -eq 0 ]; then
        break
    fi

    echo "$JSON" | jq -r '
        .contacts[] |
        [
            .id,
            .fields.all.firstname,
            .fields.all.lastname,
            .fields.all.email,
            .fields.all.phone,
            .fields.all.company
        ] | @csv
    ' >> "$OUT"

    START=$((START + COUNT))

    echo "Exported ${START} of ${TOTAL} contacts..."

    if [ "$START" -ge "$TOTAL" ]; then
        break
    fi
done

echo "Done. Exported ${START} contacts to ${OUT}"

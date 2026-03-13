#!/bin/bash
# CRM System - Customer Relationship Management
# Usage: ./crm-system.sh [add|list|follow|stats]

CRM_DIR="${HOME}/.openclaw/crm"
CUSTOMERS_FILE="${CRM_DIR}/customers.json"
FEISHU_WEBHOOK="${FEISHU_WEBHOOK:-}"

mkdir -p "${CRM_DIR}"
[[ ! -f "${CUSTOMERS_FILE}" ]] && echo "[]" > "${CUSTOMERS_FILE}"

add_customer() {
    local name="$1" contact="$2" source="$3" intent="${4:-low}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local id=$(date +%s)

    local customer=$(cat <<EOF
{
  "id": "${id}",
  "name": "${name}",
  "contact": "${contact}",
  "source": "${source}",
  "intent": "${intent}",
  "created": "${timestamp}",
  "lastFollow": null,
  "status": "new"
}
EOF
)

    jq ". += [${customer}]" "${CUSTOMERS_FILE}" > "${CUSTOMERS_FILE}.tmp"
    mv "${CUSTOMERS_FILE}.tmp" "${CUSTOMERS_FILE}"

    echo "✅ Customer added: ${name} (${intent} intent)"

    [[ "${intent}" == "high" && -n "${FEISHU_WEBHOOK}" ]] && {
        curl -s -X POST "${FEISHU_WEBHOOK}" \
            -H "Content-Type: application/json" \
            -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"🔥 High Intent Customer\\n${name}\\n${contact}\\nSource: ${source}\"}}"
    }
}

list_customers() {
    jq -r '.[] | "[\(.intent)] \(.name) - \(.contact) (\(.status))"' "${CUSTOMERS_FILE}"
}

follow_up() {
    local id="$1" note="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    jq "map(if .id == \"${id}\" then .lastFollow = \"${timestamp}\" | .status = \"following\" else . end)" \
        "${CUSTOMERS_FILE}" > "${CUSTOMERS_FILE}.tmp"
    mv "${CUSTOMERS_FILE}.tmp" "${CUSTOMERS_FILE}"

    echo "✅ Follow-up recorded for customer ${id}"
}

stats() {
    local total=$(jq 'length' "${CUSTOMERS_FILE}")
    local high=$(jq '[.[] | select(.intent == "high")] | length' "${CUSTOMERS_FILE}")
    local converted=$(jq '[.[] | select(.status == "converted")] | length' "${CUSTOMERS_FILE}")

    echo "📊 CRM Stats"
    echo "Total: ${total}"
    echo "High Intent: ${high}"
    echo "Converted: ${converted}"
    [[ ${total} -gt 0 ]] && echo "Conversion Rate: $(( converted * 100 / total ))%"
}

case "${1:-list}" in
    add) add_customer "$2" "$3" "$4" "$5" ;;
    list) list_customers ;;
    follow) follow_up "$2" "$3" ;;
    stats) stats ;;
    *) echo "Usage: $0 [add|list|follow|stats]" ;;
esac

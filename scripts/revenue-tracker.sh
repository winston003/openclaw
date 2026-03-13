#!/bin/bash
# Revenue Tracker - Track income and generate reports
# Usage: ./revenue-tracker.sh [add|daily|weekly|monthly]

REV_DIR="${HOME}/.openclaw/revenue"
REV_FILE="${REV_DIR}/transactions.json"
FEISHU_WEBHOOK="${FEISHU_WEBHOOK:-}"

mkdir -p "${REV_DIR}"
[[ ! -f "${REV_FILE}" ]] && echo "[]" > "${REV_FILE}"

add_transaction() {
    local amount="$1" source="$2" note="${3:-}"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local date=$(date +"%Y-%m-%d")

    local tx=$(cat <<EOF
{
  "amount": ${amount},
  "source": "${source}",
  "note": "${note}",
  "date": "${date}",
  "timestamp": "${timestamp}"
}
EOF
)

    jq ". += [${tx}]" "${REV_FILE}" > "${REV_FILE}.tmp"
    mv "${REV_FILE}.tmp" "${REV_FILE}"

    echo "✅ Transaction added: ¥${amount} from ${source}"
}

daily_report() {
    local today=$(date +"%Y-%m-%d")
    local total=$(jq "[.[] | select(.date == \"${today}\") | .amount] | add // 0" "${REV_FILE}")

    echo "📊 Daily Revenue (${today})"
    echo "Total: ¥${total}"

    [[ -n "${FEISHU_WEBHOOK}" ]] && {
        curl -s -X POST "${FEISHU_WEBHOOK}" \
            -H "Content-Type: application/json" \
            -d "{\"msg_type\":\"text\",\"content\":{\"text\":\"💰 Daily Revenue\\n${today}\\n¥${total}\"}}"
    }
}

weekly_report() {
    local week_ago=$(date -v-7d +"%Y-%m-%d")
    local total=$(jq "[.[] | select(.date >= \"${week_ago}\") | .amount] | add // 0" "${REV_FILE}")

    echo "📊 Weekly Revenue (Last 7 days)"
    echo "Total: ¥${total}"
    echo "Average: ¥$(( total / 7 ))/day"
}

monthly_report() {
    local month=$(date +"%Y-%m")
    local total=$(jq "[.[] | select(.date | startswith(\"${month}\")) | .amount] | add // 0" "${REV_FILE}")

    echo "📊 Monthly Revenue (${month})"
    echo "Total: ¥${total}"
}

case "${1:-daily}" in
    add) add_transaction "$2" "$3" "$4" ;;
    daily) daily_report ;;
    weekly) weekly_report ;;
    monthly) monthly_report ;;
    *) echo "Usage: $0 [add|daily|weekly|monthly]" ;;
esac

#!/bin/bash
# Business Dashboard - Real-time business metrics
# Usage: ./business-dashboard.sh

CRM_DIR="${HOME}/.openclaw/crm"
REV_DIR="${HOME}/.openclaw/revenue"
CUSTOMERS_FILE="${CRM_DIR}/customers.json"
REV_FILE="${REV_DIR}/transactions.json"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Business Dashboard - $(date +"%Y-%m-%d %H:%M")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# CRM Metrics
if [[ -f "${CUSTOMERS_FILE}" ]]; then
    total_customers=$(jq 'length' "${CUSTOMERS_FILE}")
    high_intent=$(jq '[.[] | select(.intent == "high")] | length' "${CUSTOMERS_FILE}")
    converted=$(jq '[.[] | select(.status == "converted")] | length' "${CUSTOMERS_FILE}")

    echo ""
    echo "👥 Customer Metrics"
    echo "   Total: ${total_customers}"
    echo "   High Intent: ${high_intent}"
    echo "   Converted: ${converted}"
fi

# Revenue Metrics
if [[ -f "${REV_FILE}" ]]; then
    today=$(date +"%Y-%m-%d")
    month=$(date +"%Y-%m")

    daily_rev=$(jq "[.[] | select(.date == \"${today}\") | .amount] | add // 0" "${REV_FILE}")
    monthly_rev=$(jq "[.[] | select(.date | startswith(\"${month}\")) | .amount] | add // 0" "${REV_FILE}")

    echo ""
    echo "💰 Revenue Metrics"
    echo "   Today: ¥${daily_rev}"
    echo "   This Month: ¥${monthly_rev}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

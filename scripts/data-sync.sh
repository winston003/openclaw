#!/bin/bash
# Data Sync - Sync data between dev and prod
# Usage: ./data-sync.sh [dev-to-prod|prod-to-dev|status]

DEV_DIR="${HOME}/.openclaw-dev"
PROD_DIR="${HOME}/.openclaw"

show_status() {
    echo "📊 Data Status"
    echo ""
    echo "DEV Environment:"
    [[ -f "${DEV_DIR}/crm/customers.json" ]] && echo "  CRM: $(jq 'length' ${DEV_DIR}/crm/customers.json) customers"
    [[ -f "${DEV_DIR}/revenue/transactions.json" ]] && echo "  Revenue: $(jq 'length' ${DEV_DIR}/revenue/transactions.json) transactions"

    echo ""
    echo "PROD Environment:"
    [[ -f "${PROD_DIR}/crm/customers.json" ]] && echo "  CRM: $(jq 'length' ${PROD_DIR}/crm/customers.json) customers"
    [[ -f "${PROD_DIR}/revenue/transactions.json" ]] && echo "  Revenue: $(jq 'length' ${PROD_DIR}/revenue/transactions.json) transactions"
}

dev_to_prod() {
    echo "⚠️  Syncing DEV → PROD (this will overwrite prod data)"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

    mkdir -p "${PROD_DIR}"/{crm,revenue,content}
    cp -r "${DEV_DIR}"/{crm,revenue,content} "${PROD_DIR}/" 2>/dev/null
    echo "✅ Synced to production"
}

prod_to_dev() {
    echo "⚠️  Syncing PROD → DEV (this will overwrite dev data)"
    read -p "Continue? (y/N) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0

    mkdir -p "${DEV_DIR}"/{crm,revenue,content}
    cp -r "${PROD_DIR}"/{crm,revenue,content} "${DEV_DIR}/" 2>/dev/null
    echo "✅ Synced to dev"
}

case "${1:-status}" in
    dev-to-prod) dev_to_prod ;;
    prod-to-dev) prod_to_dev ;;
    status) show_status ;;
    *) echo "Usage: $0 [dev-to-prod|prod-to-dev|status]" ;;
esac

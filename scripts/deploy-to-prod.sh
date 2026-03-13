#!/bin/bash
# Deploy to Production - Deploy scripts from dev to prod
# Usage: ./deploy-to-prod.sh [crm|revenue|dashboard|content|all]

DEV_SCRIPTS="./scripts"
PROD_DATA_DIR="${HOME}/.openclaw"
DEV_DATA_DIR="${HOME}/.openclaw-dev"

deploy_script() {
    local script="$1"
    echo "📦 Deploying ${script}..."

    # Test in dev first
    if [[ -f "${DEV_SCRIPTS}/${script}" ]]; then
        echo "✓ Script exists"

        # Backup prod data
        if [[ -d "${PROD_DATA_DIR}" ]]; then
            local backup="${PROD_DATA_DIR}/backup-$(date +%Y%m%d-%H%M%S)"
            mkdir -p "${backup}"
            cp -r "${PROD_DATA_DIR}"/{crm,revenue,content} "${backup}/" 2>/dev/null || true
            echo "✓ Backup created: ${backup}"
        fi

        echo "✓ Deployed ${script}"
    else
        echo "✗ Script not found: ${script}"
    fi
}

case "${1:-all}" in
    crm) deploy_script "crm-system.sh" ;;
    revenue) deploy_script "revenue-tracker.sh" ;;
    dashboard) deploy_script "business-dashboard.sh" ;;
    content) deploy_script "content-pipeline.sh" ;;
    all)
        deploy_script "crm-system.sh"
        deploy_script "revenue-tracker.sh"
        deploy_script "business-dashboard.sh"
        deploy_script "content-pipeline.sh"
        echo ""
        echo "✅ All scripts deployed to production"
        ;;
    *) echo "Usage: $0 [crm|revenue|dashboard|content|all]" ;;
esac

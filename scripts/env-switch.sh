#!/bin/bash
# Environment Switcher - Switch between dev and prod
# Usage: ./env-switch.sh [dev|prod|status]

show_status() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 OpenClaw Environment Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Check dev
    if pnpm openclaw --dev health &>/dev/null; then
        echo "🟢 DEV:  Running (http://127.0.0.1:19001)"
    else
        echo "⚫ DEV:  Stopped"
    fi

    # Check prod
    if pnpm openclaw health &>/dev/null; then
        echo "🟢 PROD: Running (http://127.0.0.1:19000)"
    else
        echo "⚫ PROD: Stopped"
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

switch_to_dev() {
    echo "🔄 Switching to DEV environment..."
    pnpm openclaw stop &>/dev/null || true
    ./scripts/dev-restart.sh
}

switch_to_prod() {
    echo "🔄 Switching to PROD environment..."
    pkill -f "openclaw.*--dev" &>/dev/null || true
    pnpm openclaw gateway --force
}

case "${1:-status}" in
    dev) switch_to_dev ;;
    prod) switch_to_prod ;;
    status) show_status ;;
    *) echo "Usage: $0 [dev|prod|status]" ;;
esac

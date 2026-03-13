#!/bin/bash
# Setup Notifications - Configure cron jobs for notifications
# Usage: ./setup-notifications.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "📅 Setting up notification cron jobs..."

# Add to crontab
(crontab -l 2>/dev/null; cat <<EOF

# OpenClaw Notifications
0 */2 * * * ${SCRIPT_DIR}/github-watch.sh check
0 23 * * * ${SCRIPT_DIR}/github-watch.sh daily-summary
0 */4 * * * ${SCRIPT_DIR}/news-digest.sh
EOF
) | crontab -

echo "✅ Cron jobs configured:"
echo "  - GitHub check: every 2 hours"
echo "  - Daily summary: 23:00"
echo "  - News digest: every 4 hours"
echo ""
echo "View with: crontab -l"

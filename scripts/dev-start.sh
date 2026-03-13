#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

echo "🦞 Starting OpenClaw in dev mode..."

# Check if gateway is already running
if pnpm openclaw health &>/dev/null; then
  echo "✓ Gateway already running"
  pnpm openclaw status
  exit 0
fi

# Start gateway in dev mode
pnpm openclaw --dev gateway --force

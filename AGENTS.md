# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

OpenClaw is a personal AI assistant gateway that connects multiple messaging channels (Telegram, Discord, Slack, WhatsApp, Signal, iMessage, etc.) to AI models. It's a TypeScript/Node.js project with mobile apps (iOS/Android) and a macOS app.

- **Repo**: https://github.com/openclaw/openclaw
- **Runtime**: Node ≥22
- **Package Manager**: pnpm (primary), bun supported for TS execution
- **Language**: TypeScript (ESM), Swift (iOS/macOS), Kotlin (Android)

## Essential Commands

### Development

```bash
pnpm install              # Install dependencies
pnpm dev                  # Run CLI in dev mode
pnpm openclaw [cmd]       # Run CLI commands via bun
node scripts/run-node.mjs # Alternative CLI entry
```

### Build & Type Check

```bash
pnpm build               # Full build (includes canvas bundle, protocol gen, etc.)
pnpm tsgo                # TypeScript type check only
pnpm build:strict-smoke  # Faster build for smoke testing
```

### Testing

```bash
pnpm test                # Run all tests (parallel)
pnpm test:fast           # Unit tests only
pnpm test:gateway        # Gateway tests (forked)
pnpm test:e2e            # End-to-end tests
pnpm test:coverage       # With coverage report
pnpm test:watch          # Watch mode

# Single test file
vitest run path/to/file.test.ts

# Live tests (requires real credentials)
OPENCLAW_LIVE_TEST=1 pnpm test:live
```

### Linting & Formatting

```bash
pnpm check              # Run all checks (format, lint, type-check)
pnpm format             # Format with oxfmt
pnpm format:check       # Check formatting only
pnpm lint               # Lint with oxlint (type-aware)
pnpm lint:fix           # Auto-fix lint issues
```

### Platform-Specific

**iOS**

```bash
pnpm ios:open           # Generate Xcode project and open
pnpm ios:build          # Build iOS app
pnpm ios:run            # Build and run in simulator
```

**Android**

```bash
pnpm android:assemble   # Build APK
pnpm android:install    # Install on device
pnpm android:run        # Install and launch
pnpm android:test       # Run unit tests
```

**macOS**

```bash
pnpm mac:package        # Package macOS app
pnpm mac:restart        # Restart gateway via app
```

## Architecture

### Core Structure

```
src/
├── agents/          # AI agent core (Pi agent integration)
├── gateway/         # Gateway server (WebSocket, protocol, auth)
├── channels/        # Channel routing and shared channel logic
├── telegram/        # Telegram channel implementation
├── discord/         # Discord channel implementation
├── slack/           # Slack channel implementation
├── signal/          # Signal channel implementation
├── imessage/        # iMessage channel implementation
├── cli/             # CLI framework and entry points
├── commands/        # CLI command implementations
├── config/          # Configuration management
├── browser/         # Browser automation (Playwright)
├── hooks/           # Event hooks system
├── cron/            # Scheduled tasks
├── daemon/          # Daemon/service management (launchd/systemd)
├── canvas-host/     # Canvas rendering (A2UI)
└── plugin-sdk/      # Plugin SDK exports

extensions/          # Channel and feature plugins (workspace packages)
├── msteams/         # Microsoft Teams
├── matrix/          # Matrix
├── zalo/            # Zalo
├── voice-call/      # Voice calling
├── memory-core/     # Memory system
└── ...              # 40+ extensions

apps/
├── macos/           # macOS app (Swift/SwiftUI)
├── ios/             # iOS app (Swift/SwiftUI)
└── android/         # Android app (Kotlin)

docs/                # Documentation (Mintlify)
scripts/             # Build and utility scripts
```

### Key Concepts

**Gateway**: The core server that manages connections between channels and AI agents. Runs as a daemon (launchd/systemd) or standalone. Protocol defined in `src/gateway/protocol/`.

**Channels**: Messaging platform integrations. Core channels live in `src/`, extensions in `extensions/`. Each channel implements a common interface for sending/receiving messages.

**Agents**: AI assistant logic powered by Pi agent core (`@mariozechner/pi-*` packages). Agent sessions, context, and tool execution happen here.

**Plugins**: Extensions add channels, features, or integrations. Plugin SDK exports are in `src/plugin-sdk/`. Plugins use `openclaw/plugin-sdk` imports resolved via jiti aliases.

**Routing**: Message routing logic in `src/routing/` and `src/channels/` handles allowlists, pairing, and channel-agnostic message delivery.

**Canvas**: Live UI rendering system (A2UI) for visual agent output. Bundled separately via `pnpm canvas:a2ui:bundle`.

### Plugin Development

- Extensions live under `extensions/*` as workspace packages
- Runtime deps must be in `dependencies` (not `devDependencies`)
- Avoid `workspace:*` in `dependencies` (breaks npm install)
- Put `openclaw` in `devDependencies` or `peerDependencies`
- Install runs `npm install --omit=dev` in plugin dir

### Protocol & Type Generation

```bash
pnpm protocol:gen        # Generate protocol schema
pnpm protocol:gen:swift  # Generate Swift models
pnpm protocol:check      # Verify protocol is in sync
```

Protocol schema: `dist/protocol.schema.json`
Swift models: `apps/macos/Sources/OpenClawProtocol/GatewayModels.swift`

## Testing Notes

- Framework: Vitest with V8 coverage (70% thresholds)
- Tests colocated: `*.test.ts` (unit), `*.e2e.test.ts` (e2e)
- Memory pressure: Use `OPENCLAW_TEST_PROFILE=low OPENCLAW_TEST_SERIAL_GATEWAY=1 pnpm test`
- Docker tests: `pnpm test:docker:all` (models, gateway, onboarding, plugins)

## Code Style

- Formatting: oxfmt (Rust-based formatter)
- Linting: oxlint (type-aware)
- No `@ts-nocheck`, no disabling `no-explicit-any`
- Avoid dynamic import mixing: don't mix `await import("x")` and static `import` for same module
- No prototype mutation for sharing behavior (use explicit inheritance/composition)
- Brief comments for non-obvious logic
- Keep files under ~500 LOC when feasible
- American English spelling in all code/docs/UI

## Common Patterns

**CLI Progress**: Use `src/cli/progress.ts` (osc-progress + @clack/prompts)

**Status Output**: Use `src/terminal/table.ts` for tables with ANSI-safe wrapping

**Color Palette**: Use `src/terminal/palette.ts` (no hardcoded colors)

**Dependency Injection**: CLI commands use `createDefaultDeps()` pattern

## Important Constraints

- Never edit `node_modules` (updates overwrite)
- Never update Carbon dependency without approval
- Patched dependencies must use exact versions (no `^`/`~`)
- Dynamic imports need explicit approval
- Node 22+ baseline (keep Node + Bun paths working)
- macOS gateway runs via menubar app (no separate LaunchAgent)

## Release & Version

- Version locations: `package.json`, `apps/android/app/build.gradle.kts`, iOS/macOS `Info.plist` files
- Release channels: stable (latest), beta (beta), dev (main)
- Release docs: `docs/reference/RELEASING.md`, `docs/platforms/mac/release.md`
- Never change versions without explicit approval

## Documentation

- Docs hosted on Mintlify: https://docs.openclaw.ai
- Internal links: root-relative, no `.md` extension (e.g., `[Config](/configuration)`)
- Chinese docs: `docs/zh-CN/` (generated, don't edit directly)
- Translation: `scripts/docs-i18n` with glossary in `docs/.i18n/`

## Useful Scripts

```bash
scripts/committer "<msg>" <files>  # Scoped git commits
scripts/clawlog.sh                 # Query macOS unified logs
scripts/restart-mac.sh             # Restart macOS gateway
scripts/package-mac-app.sh         # Package macOS app
scripts/ios-configure-signing.sh   # Configure iOS signing
```

## Multi-Platform Notes

- **macOS**: Use `scripts/clawlog.sh` for logs, restart via app or `scripts/restart-mac.sh`
- **iOS**: Team ID lookup via `security find-identity -p codesigning -v`
- **Android**: Prefer real devices over emulators when available
- **Linux**: Gateway runs as systemd user service
- **Windows**: WSL2 strongly recommended

## Getting Help

- Discord: https://discord.gg/clawd
- Docs: https://docs.openclaw.ai
- Issues: https://github.com/openclaw/openclaw/issues
- Run `openclaw doctor` for diagnostics

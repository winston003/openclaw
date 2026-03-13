# 开发-生产环境管理指南

## 环境架构

**开发环境** (`~/.openclaw-dev/`)

- 端口: 19001
- 用途: 测试、调试、实验
- 数据: 测试数据

**生产环境** (`~/.openclaw/`)

- 端口: 19000
- 用途: 真实业务运行
- 数据: 真实客户和收入数据

## 管理工具

### 1. 环境切换

```bash
# 查看状态
./scripts/env-switch.sh status

# 切换到开发环境
./scripts/env-switch.sh dev

# 切换到生产环境
./scripts/env-switch.sh prod
```

### 2. 部署到生产

```bash
# 部署所有脚本
./scripts/deploy-to-prod.sh all

# 部署单个脚本
./scripts/deploy-to-prod.sh crm
./scripts/deploy-to-prod.sh revenue
```

### 3. 数据同步

```bash
# 查看数据状态
./scripts/data-sync.sh status

# 开发数据 → 生产（谨慎使用）
./scripts/data-sync.sh dev-to-prod

# 生产数据 → 开发（用于调试）
./scripts/data-sync.sh prod-to-dev
```

## 工作流程

### 开发新功能

1. 在 dev 环境测试
2. 验证功能正常
3. 部署到生产
4. 监控运行状态

### 调试生产问题

1. 同步生产数据到 dev
2. 在 dev 环境复现问题
3. 修复并测试
4. 部署修复到生产

## 最佳实践

1. **永远先在 dev 测试**
2. **定期备份生产数据**
3. **部署前检查状态**
4. **保持两套环境配置同步**

# Claude Code 通用 Skills 插件模板 ()

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

一套开箱即用的 Claude Code 插件，包含 9 个通用 skills，覆盖代码开发全流程。

## 📦 包含的 Skills

| Skill | 调用命令 | 功能 |
|-------|----------|------|
| code-review | `/team-toolkit:code-review` | 全面代码审查 |
| error-investigation | `/team-toolkit:error-investigation` | 系统化错误调查 |
| refactor | `/team-toolkit:refactor` | 安全重构代码 |
| performance-optimize | `/team-toolkit:performance-optimize` | 性能分析优化 |
| api-docs | `/team-toolkit:api-docs` | API 文档生成 |
| git-commit | `/team-toolkit:git-commit` | Git 提交信息生成 |
| ui-review | `/team-toolkit:ui-review` | UI 代码审查 |
| test-generator | `/team-toolkit:test-generator` | 测试代码生成 |
| type-safety | `/team-toolkit:type-safety` | TypeScript 类型安全 |

## 🚀 快速开始

### 方式一：本地测试

```bash
# 进入插件目录
cd claude-plugin-template

# 启动 Claude Code 加载插件
claude --plugin-dir .
```

### 方式二：安装到项目

```bash
# 将整个目录复制到项目
cp -r claude-plugin-template /path/to/your/project/.claude/plugins/team-toolkit

# 或者作为 Git 子模块
git submodule add <repo-url> .claude/plugins/team-toolkit
```

## 📁 目录结构

```
team-toolkit/
├── .claude-plugin/
│   └── plugin.json          # 插件配置（必须）
├── skills/
│   ├── code-review/
│   │   └── SKILL.md
│   ├── error-investigation/
│   │   └── SKILL.md
│   ├── refactor/
│   │   └── SKILL.md
│   ├── performance-optimize/
│   │   └── SKILL.md
│   ├── api-docs/
│   │   └── SKILL.md
│   ├── git-commit/
│   │   └── SKILL.md
│   ├── ui-review/
│   │   └── SKILL.md
│   ├── test-generator/
│   │   └── SKILL.md
│   └── type-safety/
│       └── SKILL.md
└── README.md
```

## ⚙️ 自定义配置

### 修改命名空间

编辑 `.claude-plugin/plugin.json`：

```json
{
  "name": "your-team-name",
  "description": "Your custom skills"
}
```

修改 `name` 后，调用命令变为 `/your-team-name:skill-name`。

### 添加新 Skill

1. 在 `skills/` 目录下创建新文件夹
2. 创建 `SKILL.md` 文件，参考现有格式
3. 在 `plugin.json` 的 `keywords` 中添加关键词

### 调整路径作用域

每个 skill 的 `SKILL.md` 中可以配置路径作用域：

```yaml
scope:
  paths:
    - "src/**/*.{ts,tsx}"      # 只在 src 目录生效
    - "!**/*.test.ts"          # 排除测试文件
```

## 📤 分发给团队

### 方式一：GitHub 仓库

1. 将插件目录推送到独立仓库
2. 创建 `marketplace.json`：
```json
{
  "name": "team-marketplace",
  "plugins": [
    {
      "name": "team-toolkit",
      "source": "github",
      "repo": "your-org/team-toolkit"
    }
  ]
}
```
3. 团队成员安装：
```bash
/plugin marketplace add https://github.com/your-org/team-marketplace
/plugin install team-toolkit@team-marketplace
```

### 方式二：npm 包

1. 在 `package.json` 中配置
2. 发布到 npm
3. 团队成员安装：
```bash
/plugin install team-toolkit@npm
```

## 🔧 最佳实践

1. **先用后打包**：先在个人项目中使用，稳定后再打包成插件
2. **版本管理**：使用 semver 版本号，避免自动更新导致团队混乱
3. **路径作用域**：给 skills 设置合理的路径范围，避免全局生效
4. **避免硬编码**：使用环境变量替代绝对路径
5. **保持简洁**：每个 skill 聚焦一个功能，避免过于复杂

## 🐛 常见问题

**Q: 为什么 skill 没有生效？**
A: 检查是否把组件放错了位置。只有 `plugin.json` 在 `.claude-plugin/` 目录，其他都在插件根目录。

**Q: 如何更新已安装的插件？**
A: 在市场中更新版本号或 commit SHA，用户下次启动会自动更新。

**Q: 可以混合使用个人和团队插件吗？**
A: 可以，插件之间通过命名空间隔离，不会冲突。

# Claude Code 通用 Skills 插件模板 - 团队版

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

一套开箱即用的 Claude Code 插件，包含 9 个通用 skills，覆盖代码开发全流程。

- 把一套能跑通的配置变成可安装、可版本管理、可分发的单元。相当于把你的 .claude/ 打包成了一个"团队版"，别人一条命令就能装上。

## 🔍 为什么需要这个插件

### 它解决了什么问题

日常使用 Claude Code 开发时，你可能遇到过这些场景：

1. **重复编写提示词**：每次让 Claude 做代码审查、生成提交信息、排查错误，都要从零写一大段提示词，效率低下且质量不稳定。
2. **团队协作不一致**：每个人定义自己的工作流，代码审查标准、提交规范、重构策略各不相同，导致产出质量参差不齐。
3. **最佳实践难沉淀**：踩过的坑、总结出的好习惯，散落在个人笔记和聊天记录里，无法形成团队共享的知识资产。
4. **安全意识薄弱**：缺少统一的高风险操作拦截机制，`rm -rf`、敏感信息泄露等误操作难以预防。
5. **工具链碎片化**：90% 的开发任务（审查、调试、重构、文档、测试）都需要相似的上下文和步骤，却没有统一的入口。

### 它带来了什么价值

- **开箱即用**：9 个 skills 覆盖代码开发全流程——审查、调试、重构、性能优化、文档生成、测试生成、类型安全、UI 审查、Git 提交，一条命令全部就位。
- **团队一致**：统一的审查标准和工作流，消除"每个人做法不同"的问题。
- **可版本管理**：基于 semver，插件随项目演进而更新，团队成员同步升级。
- **安全兜底**：Pre-tool hook 自动拦截危险操作，Pre-commit hook 拦截敏感信息硬编码。
- **可扩展**：基于 SKILL.md 规范，新增一个 skill 只需一个 Markdown 文件，零代码门槛。

> 简单来说：这个插件把「一个经验丰富的开发者的工作习惯」打包成了可分发的技能包，让整个团队都能受益。

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

## 安装

### 方式一：从市场安装（推荐）

```bash
# 添加市场
/plugin marketplace add https://github.com/hswyxj/claude-plugin-template

# 安装插件
/plugin install team-toolkit@team-plugins
```

### 方式二：本地测试

```bash
# 在插件目录下启动 Claude Code
claude --plugin-dir .
```

### 方式三：复制到项目

```bash
# 复制到项目的 .claude/plugins/ 目录
cp -r /path/to/team-toolkit /path/to/project/.claude/plugins/team-toolkit
```

## Hooks

本插件包含 3 个 hooks：

### Stop Hook - 自动更新 CLAUDE.md

会话结束时自动检查并更新 CLAUDE.md 中的日期，保持文档最新。

### Pre-commit Hook - 代码质量检查

提交前检查：
- 未处理的 `console.log`
- `TODO`/`FIXME` 注释（仅警告）
- 敏感信息硬编码

### Pre-tool Hook - 安全拦截

对高风险操作（如 `rm -rf`、修改系统文件）进行拦截，防止误操作。

> **注意：** Hook 脚本需要 POSIX shell（Git Bash / WSL / macOS / Linux）。

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


## 打赏

如果这个项目对你有帮助，欢迎请作者喝杯咖啡 ☕

<img src="hsw.jpg" alt="打赏二维码" width="300" />

> 您的每一份支持都是我持续维护的动力，感谢！

## License

MIT


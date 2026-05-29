# 贡献指南

感谢你对 Claude Code Skills 插件模板的关注！我们欢迎各种形式的贡献。

## 🐛 报告问题

如果你发现了 bug 或有功能建议，请通过 GitHub Issues 提交，并尽量包含：

- 清晰的问题描述
- 复现步骤
- 期望行为 vs 实际行为
- 环境信息（操作系统、Claude Code 版本等）

## 🔧 提交代码

### 开发流程

1. Fork 本仓库
2. 创建你的特性分支：`git checkout -b feature/amazing-feature`
3. 提交你的改动：`git commit -m 'feat: 添加某个特性'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 创建一个 Pull Request

### 提交规范

我们遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

- `feat:` 新功能
- `fix:` Bug 修复
- `docs:` 文档更新
- `style:` 代码格式（不影响功能）
- `refactor:` 重构
- `perf:` 性能优化
- `test:` 测试相关
- `chore:` 构建/工具变动

### 代码规范

- 保持 SKILL.md 格式一致
- 确保每个 skill 聚焦单一功能
- 添加必要的使用示例
- 更新 README 中的相关文档
- Hook 脚本使用 POSIX shell 语法，兼容 Git Bash / WSL / macOS / Linux
- Hook 脚本通过 `${CLAUDE_PLUGIN_ROOT}` 获取插件根目录，禁止硬编码绝对路径

## 📝 添加新 Skill

如果你想添加新的 skill：

1. 在 `skills/` 目录下创建新文件夹
2. 创建 `SKILL.md`，参考现有 skill 的格式
3. 在 `plugin.json` 的 `keywords` 中添加相关关键词
4. 更新 README 中的 skills 列表
5. 添加使用示例

### Skill 模板

```yaml
---
name: your-skill-name
description: 简短描述这个 skill 的功能
allowed-tools: Read, Grep, Glob, Write, Bash
scope:
  paths:
    - "**/*.{ts,tsx,js,jsx}"
    - "!**/*.test.ts"
---

# Skill 标题

更详细的描述...

## 使用场景

- 场景 1
- 场景 2

## 执行流程

1. 步骤 1
2. 步骤 2

## 输出格式

预期的输出格式说明...
```

### Skill 开发要点

- **`allowed-tools`**：只声明 skill 实际需要的工具，遵循最小权限原则
- **`scope.paths`**：设置路径作用域，避免 skill 在不相关的文件上触发
- **单一职责**：每个 skill 只解决一个问题，复杂流程拆成多个 skill
- **幂等性**：同一输入多次执行，结果应一致
- **可测试**：提供明确的测试用例，方便验证 skill 是否正常工作

## 🔧 添加新 Hook

如果你想添加新的 hook：

1. 在 `hooks/scripts/` 下创建新的 shell 脚本
2. 在 `hooks/hooks.json` 中注册 hook，指定触发时机
3. 脚本通过 `${CLAUDE_PLUGIN_ROOT}` 获取插件根目录
4. 脚本需有执行权限：`chmod +x hooks/scripts/xxx.sh`

### Hook 类型

| 类型 | 触发时机 | 典型用途 |
|------|----------|----------|
| `Stop` | 会话结束时 | 更新文档、同步状态 |
| `PreToolUse` | 工具调用前 | 安全拦截、参数校验 |
| `PostToolUse` | 工具调用后 | 日志记录、结果处理 |
| `PreCommit` | 提交前 | 代码质量检查、格式化 |

### Hook 开发要点

- **POSIX 兼容**：使用 POSIX shell 语法，不依赖 bash 特性
- **退出码规范**：`0` 表示通过，非 `0` 表示拦截/失败
- **环境变量**：通过 `CLAUDE_TOOL_NAME`、`CLAUDE_TOOL_ARGS` 等获取上下文
- **错误信息**：拦截时输出清晰的错误提示，说明原因和建议

## ❓ 有疑问？

如果有任何问题，欢迎通过 Issue 或 Discussion 与我们交流！

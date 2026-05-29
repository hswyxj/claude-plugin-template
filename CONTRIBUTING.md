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
allowed-tools: Read, Grep, Glob, Write
scope:
  paths:
    - "**/*.{ts,tsx,js,jsx}"
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

## ❓ 有疑问？

如果有任何问题，欢迎通过 Issue 或 Discussion 与我们交流！

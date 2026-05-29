---
name: git-commit
description: 生成规范的 Git 提交信息，遵循 Conventional Commits 规范
allowed-tools: Read, Bash, Git
scope:
  paths:
    - "**/*"
---

# Git 提交信息生成 Skill

分析代码变更，生成符合规范的提交信息。

## 使用场景

- 规范团队提交历史
- 自动生成 CHANGELOG
- 语义化版本管理

## 提交规范

遵循 Conventional Commits：

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

| Type | 说明 |
|------|------|
| feat | 新功能 |
| fix | Bug 修复 |
| docs | 文档更新 |
| style | 代码格式（不影响功能） |
| refactor | 重构 |
| perf | 性能优化 |
| test | 测试相关 |
| chore | 构建/工具变动 |
| ci | CI 配置 |
| revert | 回滚 |

### 示例

```bash
# 简单提交
feat(auth): 添加用户登录功能

# 详细提交
fix(api): 修复分页参数验证问题

- 添加 page 和 limit 参数的边界检查
- 修复当 page=0 时的异常行为

Closes #123

# 破坏性变更
feat!: 重构用户认证接口

BREAKING CHANGE: 移除了 v1 版本的认证接口
```

## 执行流程

1. 运行 `git diff --cached` 查看暂存内容
2. 分析变更类型和影响范围
3. 生成符合规范的提交信息
4. 提示用户确认

## 输出格式

```markdown
## 建议的提交信息

### 类型
feat

### 范围
auth

### 主题
添加用户登录功能

### 详情
- 实现 JWT token 生成和验证
- 添加登录 API 端点
- 集成用户密码加密

### 关联 Issue
Closes #42

### 完整命令
git commit -m "feat(auth): 添加用户登录功能" -m "- 实现 JWT token 生成和验证" -m "- 添加登录 API 端点" -m "- 集成用户密码加密" -m "Closes #42"
```

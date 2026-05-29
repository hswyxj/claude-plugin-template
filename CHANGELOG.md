# 更新日志

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.1.0] - 2026-05-30

### 新增

- 🔧 Hooks 自动化体系：
  - Stop Hook：会话结束自动更新 CLAUDE.md 日期
  - Pre-commit Hook：提交前检查 console.log / TODO / 敏感信息硬编码
  - Pre-tool Hook：高风险操作（rm -rf、系统文件修改等）安全拦截
- 🏪 Marketplace 市场配置（`marketplace.json`）
- 📖 README 新增「为什么需要这个插件」板块，阐述痛点与价值

### 改进

- 优化 README 结构，新增安装方式对比和最佳实践

## [1.0.0] - 2026-05-29

### 新增

- 🎉 初始版本发布
- 9 个通用 Claude Code Skills：
  - `code-review`: 全面代码审查
  - `error-investigation`: 系统化错误调查
  - `refactor`: 安全重构代码
  - `performance-optimize`: 性能分析优化
  - `api-docs`: API 文档生成
  - `git-commit`: Git 提交信息生成
  - `ui-review`: UI 代码审查
  - `test-generator`: 测试代码生成
  - `type-safety`: TypeScript 类型安全
- 完整的 README 文档
- 自定义配置支持
- 多种分发方式（Git 子模块、npm 包）

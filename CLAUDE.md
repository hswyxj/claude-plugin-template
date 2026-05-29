# Team-Toolkit 插件开发指引

## 项目结构

```
team-toolkit/
├── .claude-plugin/
│   ├── plugin.json          # 插件元数据
│   └── marketplace.json     # 市场配置
├── hooks/
│   ├── hooks.json           # Hooks 配置
│   └── scripts/
│       ├── update-claude-md.sh    # Stop hook：自动更新 CLAUDE.md
│       ├── pre-commit-check.sh    # Pre-commit：代码质量检查
│       └── safety-check.sh        # Pre-tool：安全拦截
├── skills/                  # 9 个通用 skills
├── CLAUDE.md                # 本文件
├── README.md                # 使用说明
├── CHANGELOG.md             # 版本更新日志
├── CONTRIBUTING.md          # 贡献指南
└── LICENSE                  # MIT 许可证
```

## 开发规范

### 新增 Skill

1. 在 `skills/` 下创建新目录，目录名即 skill 名称
2. 创建 `SKILL.md` 文件，包含 YAML frontmatter 和内容
3. 更新 `README.md` 中的 skills 列表

### 修改 Hooks

1. 修改 `hooks/hooks.json` 添加新 hook
2. 在 `hooks/scripts/` 下创建对应脚本
3. 确保脚本有执行权限：`chmod +x hooks/scripts/xxx.sh`
4. 从脚本位置推导 PLUGIN_ROOT，不要用 $(pwd) 回退

### 测试方法

#### 本地测试插件

```bash
# 在插件目录下启动 Claude Code
claude --plugin-dir .

# 或在 Claude Code 中重新加载
/reload-plugins
```

#### 测试 hooks

```bash
# 测试 stop hook
CLAUDE_PLUGIN_ROOT=. bash hooks/scripts/update-claude-md.sh

# 测试 pre-commit hook（需要先 git add 文件）
CLAUDE_PLUGIN_ROOT=. bash hooks/scripts/pre-commit-check.sh

# 测试 pre-tool hook
CLAUDE_TOOL_NAME="Bash" CLAUDE_TOOL_ARGS="ls -la" bash hooks/scripts/safety-check.sh
```

## 版本管理

- 使用语义化版本（semver）：`major.minor.patch`
- 修改 `plugin.json` 中的 `version` 字段
- 更新 `CHANGELOG.md` 记录变更

## 分发

### 从市场安装（推荐）

```bash
# 添加市场
/plugin marketplace add https://github.com/hswyxj/claude-plugin-template

# 安装插件
/plugin install team-toolkit@team-plugins
```

### 本地安装

```bash
# 复制到项目的 .claude/plugins/ 目录
cp -r . /path/to/project/.claude/plugins/team-toolkit
```

## 注意事项

- 不要将 API key 硬编码在脚本中，使用环境变量
- Hook 脚本使用 `${CLAUDE_PLUGIN_ROOT}` 而非绝对路径
- 新增功能前先在 `.claude/` 中验证，稳定后再打包进插件
- Hook 脚本需要 POSIX shell（Git Bash / WSL / macOS / Linux）

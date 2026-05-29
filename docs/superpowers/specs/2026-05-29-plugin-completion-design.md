# Team-Toolkit 插件完善设计

> **目标：** 在现有 9 个 skills 基础上，补充 hooks、市场分发机制和文档，让插件真正能给团队使用。

## 背景

当前 team-toolkit 插件只有 skills，缺少 hooks、市场分发和完整文档。需要补齐这些组件，让 2-5 人小团队能一键安装并使用。

## 设计范围

### 1. Hooks 设计

新增 `hooks/hooks.json`，包含 3 个 hooks：

#### 1.1 Stop Hook — 自动更新 CLAUDE.md
- **触发时机：** 每次会话结束时
- **行为：** 检查 CLAUDE.md 是否需要更新（新增项目决策、代码规范变更等），如果有变更则自动写入
- **目的：** 让 CLAUDE.md 保持最新，新人入职能直接看到团队积累的知识

#### 1.2 Pre-commit Hook — 代码质量检查
- **触发时机：** git commit 之前
- **行为：** 检查明显的代码问题（未处理的 console.log、TODO 注释、敏感信息硬编码等）
- **目的：** 在提交前拦截低级问题

#### 1.3 Pre-tool Hook — 安全拦截
- **触发时机：** 任何工具调用前
- **行为：** 对高风险操作（删除文件、修改系统配置、执行未知脚本）进行确认
- **目的：** 防止误操作，特别是对不熟悉项目的新人

### 2. 市场分发

新增 `.claude-plugin/marketplace.json`，支持 GitHub 仓库市场安装：

```json
{
  "name": "team-plugins",
  "owner": { "name": "团队名" },
  "plugins": [
    {
      "name": "team-toolkit",
      "source": "github",
      "repo": "hswyxj/claude-plugin-template",
      "description": "团队通用 Claude Code Skills"
    }
  ]
}
```

安装命令：
```
/plugin marketplace add https://github.com/hswyxj/claude-plugin-template
/plugin install team-toolkit@team-plugins
```

### 3. 文档

#### 3.1 CLAUDE.md
插件项目指引，包含：
- 项目结构说明
- 开发规范（如何新增 skill、如何修改 hooks）
- 测试方法

#### 3.2 README.md 更新
补充：
- hooks 使用说明
- 安装指南（从市场安装）
- 贡献指南链接

## 文件结构

```
team-toolkit/
├── .claude-plugin/
│   ├── plugin.json          # 保持不变
│   └── marketplace.json     # 新增：市场配置
├── hooks/
│   ├── hooks.json           # 新增：hooks 配置
│   └── scripts/
│       ├── update-claude-md.sh    # 新增：stop hook 脚本
│       ├── pre-commit-check.sh    # 新增：pre-commit 脚本
│       └── safety-check.sh        # 新增：pre-tool 安全检查脚本
├── skills/                  # 保持不变：9 个现有 skills
├── CLAUDE.md                # 新增：项目指引
├── README.md                # 修改：补充 hooks 和安装说明
├── .gitignore               # 保持不变
├── CHANGELOG.md             # 保持不变
├── CONTRIBUTING.md          # 保持不变
└── LICENSE                  # 保持不变
```

## 不改动的部分

- 9 个现有 skills 保持不变
- `plugin.json` 保持不变
- `.gitignore`、`LICENSE`、`CHANGELOG.md`、`CONTRIBUTING.md` 保持不变

## 预估工作量

约 2-3 小时，主要是写 hooks 脚本和更新文档。

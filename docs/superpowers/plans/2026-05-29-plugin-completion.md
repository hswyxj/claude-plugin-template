# Team-Toolkit 插件完善实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有 9 个 skills 基础上，补充 hooks、市场分发机制和文档，让插件真正能给团队使用。

**Architecture:** 新增 hooks 目录（含 3 个 hook 脚本）、marketplace.json 市场配置、CLAUDE.md 项目指引，并更新 README.md 安装说明。

**Tech Stack:** Shell scripts (Bash), JSON, Markdown

---

## 文件结构映射

| 文件 | 操作 | 职责 |
|------|------|------|
| `hooks/hooks.json` | Create | 3 个 hooks 的配置定义 |
| `hooks/scripts/update-claude-md.sh` | Create | Stop hook：自动更新 CLAUDE.md |
| `hooks/scripts/pre-commit-check.sh` | Create | Pre-commit：代码质量检查 |
| `hooks/scripts/safety-check.sh` | Create | Pre-tool：高风险操作拦截 |
| `.claude-plugin/marketplace.json` | Create | GitHub 仓库市场配置 |
| `CLAUDE.md` | Create | 插件项目指引 |
| `README.md` | Modify | 补充 hooks 说明和安装指南 |

---

### Task 1: 创建 hooks 配置文件

**Files:**
- Create: `hooks/hooks.json`

- [ ] **Step 1: 创建 hooks 目录**

Run: `mkdir -p hooks/scripts`

- [ ] **Step 2: 创建 hooks.json 配置**

```json
{
  "hooks": [
    {
      "type": "stop",
      "description": "会话结束时自动更新 CLAUDE.md",
      "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/update-claude-md.sh"
    },
    {
      "type": "pre-commit",
      "description": "提交前检查代码质量",
      "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/pre-commit-check.sh"
    },
    {
      "type": "pre-tool",
      "description": "高风险操作安全拦截",
      "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/safety-check.sh"
    }
  ]
}
```

Write to: `hooks/hooks.json`

- [ ] **Step 3: 验证 JSON 格式**

Run: `cat hooks/hooks.json | python -m json.tool > /dev/null && echo "JSON valid" || echo "JSON invalid"`
Expected: `JSON valid`

- [ ] **Step 4: Commit**

```bash
git add hooks/
git commit -m "feat: add hooks configuration with 3 hooks"
```

---

### Task 2: 实现 Stop Hook 脚本

**Files:**
- Create: `hooks/scripts/update-claude-md.sh`

- [ ] **Step 1: 创建脚本文件**

```bash
#!/bin/bash
# Stop Hook: 自动更新 CLAUDE.md
# 用途：会话结束时检查并更新 CLAUDE.md 中的项目信息

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目根目录（从 CLAUDE_PLUGIN_ROOT 推导）
PROJECT_ROOT="${CLAUDE_PLUGIN_ROOT:-$(pwd)}"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

# 检查 CLAUDE.md 是否存在
if [ ! -f "$CLAUDE_MD" ]; then
    echo -e "${YELLOW}[Stop Hook] CLAUDE.md 不存在，跳过更新${NC}"
    exit 0
fi

# 获取当前日期
CURRENT_DATE=$(date +%Y-%m-%d)

# 检查 CLAUDE.md 中的最后更新日期
LAST_UPDATE=$(grep -o "最后更新: [0-9-]*" "$CLAUDE_MD" | head -1 | cut -d: -f2 | tr -d ' ')

# 如果日期相同，跳过更新
if [ "$LAST_UPDATE" = "$CURRENT_DATE" ]; then
    echo -e "${GREEN}[Stop Hook] CLAUDE.md 已是最新，跳过更新${NC}"
    exit 0
fi

# 更新 CLAUDE.md 中的日期
if grep -q "最后更新:" "$CLAUDE_MD"; then
    sed -i "s/最后更新: [0-9-]*/最后更新: $CURRENT_DATE/" "$CLAUDE_MD"
    echo -e "${GREEN}[Stop Hook] 已更新 CLAUDE.md 日期为 $CURRENT_DATE${NC}"
else
    echo -e "${YELLOW}[Stop Hook] CLAUDE.md 中未找到日期标记，跳过更新${NC}"
fi

exit 0
```

Write to: `hooks/scripts/update-claude-md.sh`

- [ ] **Step 2: 添加执行权限**

Run: `chmod +x hooks/scripts/update-claude-md.sh`

- [ ] **Step 3: 测试脚本（无 CLAUDE.md 情况）**

Run: `cd /tmp && CLAUDE_PLUGIN_ROOT=e:/tmp/claude-plugin-template bash e:/tmp/claude-plugin-template/hooks/scripts/update-claude-md.sh`
Expected: 输出 "CLAUDE.md 不存在，跳过更新"

- [ ] **Step 4: Commit**

```bash
git add hooks/scripts/update-claude-md.sh
git commit -m "feat: add stop hook script for auto-updating CLAUDE.md"
```

---

### Task 3: 实现 Pre-commit Hook 脚本

**Files:**
- Create: `hooks/scripts/pre-commit-check.sh`

- [ ] **Step 1: 创建脚本文件**

```bash
#!/bin/bash
# Pre-commit Hook: 代码质量检查
# 用途：提交前检查明显的代码问题

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 项目根目录
PROJECT_ROOT="${CLAUDE_PLUGIN_ROOT:-$(pwd)}"

# 检查结果
ERRORS=0

echo -e "${YELLOW}[Pre-commit] 开始代码质量检查...${NC}"

# 1. 检查未处理的 console.log
echo "检查 console.log..."
if grep -r "console\.log" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" "$PROJECT_ROOT" 2>/dev/null | grep -v "node_modules" | grep -v ".git" | grep -v "hooks/" | grep -v "skills/"; then
    echo -e "${RED}[Pre-commit] 发现 console.log，请移除后重新提交${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}[Pre-commit] console.log 检查通过${NC}"
fi

# 2. 检查 TODO 注释
echo "检查 TODO 注释..."
if grep -r "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" "$PROJECT_ROOT" 2>/dev/null | grep -v "node_modules" | grep -v ".git" | grep -v "hooks/" | grep -v "skills/"; then
    echo -e "${YELLOW}[Pre-commit] 发现 TODO/FIXME 注释，请确认是否需要处理${NC}"
    # TODO 不阻止提交，只警告
else
    echo -e "${GREEN}[Pre-commit] TODO 检查通过${NC}"
fi

# 3. 检查敏感信息硬编码
echo "检查敏感信息..."
if grep -r "password\|secret\|api_key\|apikey\|token" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" "$PROJECT_ROOT" 2>/dev/null | grep -v "node_modules" | grep -v ".git" | grep -v "hooks/" | grep -v "skills/" | grep -v "\.env" | grep -v "example"; then
    echo -e "${RED}[Pre-commit] 发现可能的敏感信息硬编码，请检查${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}[Pre-commit] 敏感信息检查通过${NC}"
fi

# 汇总结果
echo ""
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}[Pre-commit] 检查失败，发现 $ERRORS 个问题${NC}"
    exit 1
else
    echo -e "${GREEN}[Pre-commit] 所有检查通过${NC}"
    exit 0
fi
```

Write to: `hooks/scripts/pre-commit-check.sh`

- [ ] **Step 2: 添加执行权限**

Run: `chmod +x hooks/scripts/pre-commit-check.sh`

- [ ] **Step 3: 测试脚本（创建测试文件）**

```bash
# 创建临时测试目录
mkdir -p /tmp/test-precommit
echo 'console.log("test");' > /tmp/test-precommit/test.ts
echo 'const password = "123456";' >> /tmp/test-precommit/test.ts

# 运行检查
CLAUDE_PLUGIN_ROOT=/tmp/test-precommit bash e:/tmp/claude-plugin-template/hooks/scripts/pre-commit-check.sh
```

Expected: 输出 "发现 console.log" 和 "发现可能的敏感信息硬编码"，退出码为 1

- [ ] **Step 4: 清理测试文件**

Run: `rm -rf /tmp/test-precommit`

- [ ] **Step 5: Commit**

```bash
git add hooks/scripts/pre-commit-check.sh
git commit -m "feat: add pre-commit hook for code quality checks"
```

---

### Task 4: 实现 Pre-tool Hook 脚本

**Files:**
- Create: `hooks/scripts/safety-check.sh`

- [ ] **Step 1: 创建脚本文件**

```bash
#!/bin/bash
# Pre-tool Hook: 高风险操作安全拦截
# 用途：对高风险工具调用进行确认

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取工具名称和参数
TOOL_NAME="${1:-unknown}"
TOOL_ARGS="${2:-}"

# 高风险工具列表
HIGH_RISK_TOOLS=("Bash" "Write" "Edit" "NotebookEdit")

# 检查是否是高风险工具
IS_HIGH_RISK=false
for tool in "${HIGH_RISK_TOOLS[@]}"; do
    if [ "$TOOL_NAME" = "$tool" ]; then
        IS_HIGH_RISK=true
        break
    fi
done

# 如果不是高风险工具，直接通过
if [ "$IS_HIGH_RISK" = false ]; then
    echo -e "${GREEN}[Safety Check] 工具 $TOOL_NAME 不在高风险列表中，允许执行${NC}"
    exit 0
fi

# 检查是否包含危险操作
DANGEROUS_PATTERNS=(
    "rm -rf"
    "rm -r /"
    "dd if="
    "mkfs"
    "format"
    "> /dev/sda"
    "chmod -R 777"
    "chown -R"
)

IS_DANGEROUS=false
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$TOOL_ARGS" | grep -q "$pattern"; then
        IS_DANGEROUS=true
        echo -e "${RED}[Safety Check] 检测到危险操作: $pattern${NC}"
        break
    fi
done

# 如果检测到危险操作，需要确认
if [ "$IS_DANGEROUS" = true ]; then
    echo -e "${RED}[Safety Check] 工具 $TOOL_NAME 包含高风险操作${NC}"
    echo -e "${YELLOW}[Safety Check] 请确认是否继续执行${NC}"
    echo -e "${YELLOW}[Safety Check] 继续执行请按 y，取消请按 n${NC}"
    
    # 在非交互式环境中，默认拒绝
    if [ ! -t 0 ]; then
        echo -e "${RED}[Safety Check] 非交互式环境，拒绝执行${NC}"
        exit 1
    fi
    
    read -r -p "确认执行? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            echo -e "${GREEN}[Safety Check] 用户确认，允许执行${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}[Safety Check] 用户取消，拒绝执行${NC}"
            exit 1
            ;;
    esac
fi

# 通过安全检查
echo -e "${GREEN}[Safety Check] 工具 $TOOL_NAME 安全检查通过${NC}"
exit 0
```

Write to: `hooks/scripts/safety-check.sh`

- [ ] **Step 2: 添加执行权限**

Run: `chmod +x hooks/scripts/safety-check.sh`

- [ ] **Step 3: 测试脚本（安全工具）**

Run: `bash e:/tmp/claude-plugin-template/hooks/scripts/safety-check.sh "Read" ""`
Expected: 输出 "工具 Read 不在高风险列表中，允许执行"

- [ ] **Step 4: 测试脚本（危险操作）**

Run: `echo "n" | bash e:/tmp/claude-plugin-template/hooks/scripts/safety-check.sh "Bash" "rm -rf /tmp/test"`
Expected: 输出 "检测到危险操作: rm -rf"，退出码为 1

- [ ] **Step 5: Commit**

```bash
git add hooks/scripts/safety-check.sh
git commit -m "feat: add pre-tool hook for safety checks"
```

---

### Task 5: 创建市场配置文件

**Files:**
- Create: `.claude-plugin/marketplace.json`

- [ ] **Step 1: 创建 marketplace.json**

```json
{
  "name": "team-plugins",
  "owner": {
    "name": "团队名",
    "url": "https://github.com/hswyxj"
  },
  "plugins": [
    {
      "name": "team-toolkit",
      "source": "github",
      "repo": "hswyxj/claude-plugin-template",
      "description": "团队通用 Claude Code Skills：代码审查、调试修复、重构优化、文档生成、工作流"
    }
  ]
}
```

Write to: `.claude-plugin/marketplace.json`

- [ ] **Step 2: 验证 JSON 格式**

Run: `cat .claude-plugin/marketplace.json | python -m json.tool > /dev/null && echo "JSON valid" || echo "JSON invalid"`
Expected: `JSON valid`

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "feat: add marketplace configuration for team distribution"
```

---

### Task 6: 创建 CLAUDE.md 项目指引

**Files:**
- Create: `CLAUDE.md`

- [ ] **Step 1: 创建 CLAUDE.md**

```markdown
# Team-Toolkit 插件

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

# 测试 pre-commit hook
CLAUDE_PLUGIN_ROOT=. bash hooks/scripts/pre-commit-check.sh

# 测试 pre-tool hook
bash hooks/scripts/safety-check.sh "Bash" "ls -la"
```

## 版本管理

- 使用语义化版本（semver）：`major.minor.patch`
- 修改 `plugin.json` 中的 `version` 字段
- 更新 `CHANGELOG.md` 记录变更

## 分发

### 从市场安装

```bash
/plugin marketplace add https://github.com/hswyxj/claude-plugin-template
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
```

Write to: `CLAUDE.md`

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add CLAUDE.md project guide"
```

---

### Task 7: 更新 README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: 读取现有 README.md**

Read: `README.md`

- [ ] **Step 2: 在现有内容基础上补充 hooks 和安装说明**

在 README.md 的 "快速开始" 部分之后，添加以下内容：

```markdown
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

对高风险操作（如 `rm -rf`、修改系统文件）进行确认，防止误操作。

## 使用

安装后，使用以下命令调用 skills：

- `/team-toolkit:code-review` - 代码审查
- `/team-toolkit:error-investigation` - 错误排查
- `/team-toolkit:refactor` - 重构代码
- `/team-toolkit:performance-optimize` - 性能优化
- `/team-toolkit:api-docs` - API 文档生成
- `/team-toolkit:git-commit` - 规范提交
- `/team-toolkit:ui-review` - UI 审查
- `/team-toolkit:test-generator` - 测试生成
- `/team-toolkit:type-safety` - 类型安全检查
```

将上述内容插入到 README.md 的适当位置。

- [ ] **Step 3: 验证 Markdown 格式**

Run: `cat README.md | head -20`
Expected: 显示更新后的 README 内容

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: update README with hooks and installation guide"
```

---

### Task 8: 最终验证

**Files:**
- None (verification only)

- [ ] **Step 1: 验证目录结构**

Run: `find . -type f -name "*.json" -o -name "*.sh" -o -name "*.md" | sort`
Expected: 显示所有新增和修改的文件

- [ ] **Step 2: 验证 hooks.json 格式**

Run: `cat hooks/hooks.json | python -m json.tool`
Expected: 显示格式化的 JSON 内容

- [ ] **Step 3: 验证 marketplace.json 格式**

Run: `cat .claude-plugin/marketplace.json | python -m json.tool`
Expected: 显示格式化的 JSON 内容

- [ ] **Step 4: 验证所有脚本有执行权限**

Run: `ls -la hooks/scripts/`
Expected: 所有 .sh 文件有 x 权限

- [ ] **Step 5: 运行 pre-commit 检查测试**

Run: `CLAUDE_PLUGIN_ROOT=. bash hooks/scripts/pre-commit-check.sh`
Expected: 检查通过，退出码 0

- [ ] **Step 6: 最终 Commit**

```bash
git add -A
git commit -m "feat: complete plugin with hooks, marketplace, and documentation"
```

---

## 完成

所有任务完成后，插件将包含：

1. ✅ 3 个 hooks（stop、pre-commit、pre-tool）
2. ✅ 市场配置文件
3. ✅ 项目指引文档
4. ✅ 更新的 README

团队成员可以通过以下命令安装：

```bash
/plugin marketplace add https://github.com/hswyxj/claude-plugin-template
/plugin install team-toolkit@team-plugins
```

# Team-Toolkit 插件完善实施计划（修订版）

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在现有 9 个 skills 基础上，补充 hooks（修复全部技术问题）、市场分发、文档，并增强 2-3 个核心 skills 的深度。

**Architecture:** 新增 hooks 目录（含 3 个修复后的 hook 脚本）、marketplace.json 市场配置、CLAUDE.md 项目指引，更新 README，增强 code-review/test-generator/refactor 三个核心 skills。

**Tech Stack:** Shell scripts (Bash), JSON, Markdown

---

## 用户决策记录

| 问题 | 决策 | 理由 |
|------|------|------|
| Hooks 方向 | 保留但修复全部技术问题 | 团队需要轻量级 guardrails |
| Marketplace | 保留（API 已验证可用） | 官方分发机制，团队一条命令安装 |
| Skills 深度 | 同时做：包装 + 增强 | 不等验证，边用边改 |

---

## 文件结构映射

| 文件 | 操作 | 职责 |
|------|------|------|
| `hooks/hooks.json` | Create | 3 个 hooks 的配置定义 |
| `hooks/scripts/update-claude-md.sh` | Create | Stop hook：自动更新 CLAUDE.md |
| `hooks/scripts/pre-commit-check.sh` | Create | Pre-commit：代码质量检查 |
| `hooks/scripts/safety-check.sh` | Create | Pre-tool：高风险操作拦截 |
| `.claude-plugin/marketplace.json` | Create | GitHub 仓库市场配置 |
| `CLAUDE.md` | Create | 插件开发指引 |
| `README.md` | Modify | 补充 hooks 说明和安装指南 |
| `skills/code-review/SKILL.md` | Modify | 增强：集成 ESLint、项目特定审查标准 |
| `skills/test-generator/SKILL.md` | Modify | 增强：分析测试覆盖率缺口 |
| `skills/refactor/SKILL.md` | Modify | 增强：依赖分析、影响评估 |

---

## Eng Review 修复清单

以下技术问题在实施时必须修复：

| # | 问题 | 严重度 | 修复方案 |
|---|------|--------|----------|
| 1 | `sed -i` macOS 不兼容 | HIGH | 用 `sed -i.bak` + `rm` |
| 2 | `$(pwd)` 回退指向错误目录 | HIGH | 从脚本位置推导 `SCRIPT_DIR` |
| 3 | 敏感信息正则误报 | HIGH | 缩窄为赋值模式 `password\s*=\s*["']` |
| 4 | hook 类型名未验证 | CRITICAL | 从 Claude Code 文档确认类型字符串 |
| 5 | 交互式 `read` 是死代码 | LOW | 删除，改为 block + log |
| 6 | pre-commit 扫描全树 | MEDIUM | 改为 `git diff --cached` |
| 7 | Windows 路径不兼容 | MEDIUM | 添加 POSIX shell 说明 |
| 8 | `CLAUDE.md` 标题混淆 | LOW | 改为"插件开发指引" |
| 9 | marketplace 占位符 | MEDIUM | 用 `<your-team-name>` |
| 10 | 无集成测试 | HIGH | 添加 `claude --plugin-dir .` smoke test |

---

### Task 1: 创建 hooks 配置文件

**Files:**
- Create: `hooks/hooks.json`

- [ ] **Step 1: 创建 hooks 目录**

Run: `mkdir -p hooks/scripts`

- [ ] **Step 2: 创建 hooks.json 配置**

Write to: `hooks/hooks.json`

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

> **⚠️ CRITICAL 修复（#4）：** `type` 字段值 `"stop"`、`"pre-commit"`、`"pre-tool"` 必须从 Claude Code 插件文档确认。实施时先验证实际 API，使用正确的类型字符串。

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

Write to: `hooks/scripts/update-claude-md.sh`

```bash
#!/bin/bash
# Stop Hook: 自动更新 CLAUDE.md
# 用途：会话结束时检查并更新 CLAUDE.md 中的项目信息

set -euo pipefail

# 从脚本位置推导插件根目录（修复 #2：$(pwd) 回退问题）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$SCRIPT_DIR")")}"

# 验证插件根目录包含 plugin.json
if [ ! -f "$PLUGIN_ROOT/.claude-plugin/plugin.json" ]; then
    echo "[Stop Hook] ERROR: 无法定位插件根目录（未找到 plugin.json）" >&2
    exit 1
fi

CLAUDE_MD="$PLUGIN_ROOT/CLAUDE.md"

# 检查 CLAUDE.md 是否存在
if [ ! -f "$CLAUDE_MD" ]; then
    echo "[Stop Hook] CLAUDE.md 不存在，跳过更新"
    exit 0
fi

CURRENT_DATE=$(date +%Y-%m-%d)

# 获取当前日期
LAST_UPDATE=$(grep -o "最后更新: [0-9-]*" "$CLAUDE_MD" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' ')

# 修复 #10：显式检查空值
if [ -z "$LAST_UPDATE" ]; then
    echo "[Stop Hook] CLAUDE.md 中未找到日期标记，跳过更新"
    exit 0
fi

if [ "$LAST_UPDATE" = "$CURRENT_DATE" ]; then
    echo "[Stop Hook] CLAUDE.md 已是最新，跳过更新"
    exit 0
fi

# 修复 #1：macOS 兼容性 - 用 sed -i.bak + rm
sed -i.bak "s/最后更新: [0-9-]*/最后更新: $CURRENT_DATE/" "$CLAUDE_MD"
rm -f "$CLAUDE_MD.bak"
echo "[Stop Hook] 已更新 CLAUDE.md 日期为 $CURRENT_DATE"

exit 0
```

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

Write to: `hooks/scripts/pre-commit-check.sh`

```bash
#!/bin/bash
# Pre-commit Hook: 代码质量检查
# 用途：提交前检查暂存文件的代码质量

set -euo pipefail

# 从脚本位置推导插件根目录（修复 #2）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$SCRIPT_DIR")")}"

ERRORS=0

echo "[Pre-commit] 开始代码质量检查..."

# 修复 #6：只检查暂存文件，而非全树
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || echo "")

if [ -z "$STAGED_FILES" ]; then
    echo "[Pre-commit] 无暂存文件，跳过检查"
    exit 0
fi

# 1. 检查未处理的 console.log
echo "检查 console.log..."
CONSOLE_LOGS=$(echo "$STAGED_FILES" | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -l "console\.log" 2>/dev/null || true)
if [ -n "$CONSOLE_LOGS" ]; then
    echo "[Pre-commit] 发现 console.log，请移除后重新提交:"
    echo "$CONSOLE_LOGS"
    ERRORS=$((ERRORS + 1))
else
    echo "[Pre-commit] console.log 检查通过"
fi

# 2. 检查 TODO 注释（仅警告，不阻止提交）
echo "检查 TODO 注释..."
TODOS=$(echo "$STAGED_FILES" | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -l "TODO\|FIXME\|HACK\|XXX" 2>/dev/null || true)
if [ -n "$TODOS" ]; then
    echo "[Pre-commit] 发现 TODO/FIXME 注释（仅警告）:"
    echo "$TODOS"
else
    echo "[Pre-commit] TODO 检查通过"
fi

# 3. 检查敏感信息硬编码（修复 #3：缩窄正则为赋值模式）
echo "检查敏感信息..."
SENSITIVE=$(echo "$STAGED_FILES" | grep -E '\.(ts|tsx|js|jsx)$' | xargs grep -nE '(password|secret|api_key|apikey|token)\s*=\s*["'"'"']' 2>/dev/null || true)
if [ -n "$SENSITIVE" ]; then
    echo "[Pre-commit] 发现可能的敏感信息硬编码:"
    echo "$SENSITIVE"
    ERRORS=$((ERRORS + 1))
else
    echo "[Pre-commit] 敏感信息检查通过"
fi

# 汇总结果
echo ""
if [ $ERRORS -gt 0 ]; then
    echo "[Pre-commit] 检查失败，发现 $ERRORS 个问题"
    exit 1
else
    echo "[Pre-commit] 所有检查通过"
    exit 0
fi
```

- [ ] **Step 2: 添加执行权限**

Run: `chmod +x hooks/scripts/pre-commit-check.sh`

- [ ] **Step 3: 测试脚本（创建暂存文件）**

```bash
# 创建临时测试目录
mkdir -p /tmp/test-precommit && cd /tmp/test-precommit
git init
echo 'console.log("test");' > test.ts
echo 'const password = "123456";' >> test.ts
git add test.ts

# 运行检查
CLAUDE_PLUGIN_ROOT=e:/tmp/claude-plugin-template bash e:/tmp/claude-plugin-template/hooks/scripts/pre-commit-check.sh
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

Write to: `hooks/scripts/safety-check.sh`

```bash
#!/bin/bash
# Pre-tool Hook: 高风险操作安全拦截
# 用途：对高风险工具调用进行拦截
# 修复 #5：删除交互式 read，改为 block + log

set -euo pipefail

# 从环境变量获取工具信息（修复 #4：验证 Claude Code hook 协议）
# 注意：实际的环境变量名需从 Claude Code 文档确认
TOOL_NAME="${CLAUDE_TOOL_NAME:-${1:-unknown}}"
TOOL_ARGS="${CLAUDE_TOOL_ARGS:-${2:-}}"

# 高风险工具列表
HIGH_RISK_TOOLS=("Bash" "Write" "Edit" "NotebookEdit")

IS_HIGH_RISK=false
for tool in "${HIGH_RISK_TOOLS[@]}"; do
    if [ "$TOOL_NAME" = "$tool" ]; then
        IS_HIGH_RISK=true
        break
    fi
done

if [ "$IS_HIGH_RISK" = false ]; then
    echo "[Safety Check] 工具 $TOOL_NAME 不在高风险列表中，允许执行"
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
DETECTED_PATTERN=""
for pattern in "${DANGEROUS_PATTERNS[@]}"; do
    if echo "$TOOL_ARGS" | grep -q "$pattern"; then
        IS_DANGEROUS=true
        DETECTED_PATTERN="$pattern"
        break
    fi
done

if [ "$IS_DANGEROUS" = true ]; then
    echo "[Safety Check] 拦截: 工具 $TOOL_NAME 包含危险操作 '$DETECTED_PATTERN'" >&2
    echo "[Safety Check] 如需执行，请手动运行此命令" >&2
    exit 1
fi

echo "[Safety Check] 工具 $TOOL_NAME 安全检查通过"
exit 0
```

- [ ] **Step 2: 添加执行权限**

Run: `chmod +x hooks/scripts/safety-check.sh`

- [ ] **Step 3: 测试脚本（安全工具）**

Run: `CLAUDE_TOOL_NAME="Read" bash e:/tmp/claude-plugin-template/hooks/scripts/safety-check.sh`
Expected: 输出 "工具 Read 不在高风险列表中，允许执行"

- [ ] **Step 4: 测试脚本（危险操作）**

Run: `CLAUDE_TOOL_NAME="Bash" CLAUDE_TOOL_ARGS="rm -rf /tmp/test" bash e:/tmp/claude-plugin-template/hooks/scripts/safety-check.sh`
Expected: 输出 "拦截: 工具 Bash 包含危险操作 'rm -rf'"，退出码为 1

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

Write to: `.claude-plugin/marketplace.json`

```json
{
  "name": "team-plugins",
  "owner": {
    "name": "<your-team-name>",
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

- [ ] **Step 2: 验证 JSON 格式**

Run: `cat .claude-plugin/marketplace.json | python -m json.tool > /dev/null && echo "JSON valid" || echo "JSON invalid"`
Expected: `JSON valid`

- [ ] **Step 3: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "feat: add marketplace configuration for team distribution"
```

---

### Task 6: 增强 code-review skill

**Files:**
- Modify: `skills/code-review/SKILL.md`

- [ ] **Step 1: 读取现有 skill**

Read: `skills/code-review/SKILL.md`

- [ ] **Step 2: 增强内容**

在现有内容基础上，增加以下能力：

```markdown
## 项目特定审查

### ESLint 集成
- 检查项目是否有 .eslintrc / eslint.config.js
- 如果有，运行 `npx eslint --format json` 获取现有 lint 结果
- 将 ESLint 发现作为审查基线，不再重复报告相同问题

### 自定义规则
- 检查 CLAUDE.md 中是否有团队特定的编码规范
- 将规范作为审查标准之一

## 审查深度增强

### 除了基础维度（命名、安全、性能），增加：
- **依赖分析**：新增 import 是否引入了不必要的依赖
- **类型安全**：any 类型使用、类型断言滥用
- **错误处理**：未捕获的 Promise rejection、空的 catch 块
- **测试覆盖**：修改的函数是否有对应测试
```

- [ ] **Step 3: Commit**

```bash
git add skills/code-review/SKILL.md
git commit -m "feat: enhance code-review skill with ESLint integration and depth"
```

---

### Task 7: 增强 test-generator skill

**Files:**
- Modify: `skills/test-generator/SKILL.md`

- [ ] **Step 1: 读取现有 skill**

Read: `skills/test-generator/SKILL.md`

- [ ] **Step 2: 增强内容**

增加以下能力：

```markdown
## 测试覆盖率分析

### 覆盖率缺口检测
- 检查项目是否有 jest.config / vitest.config
- 运行 `npx jest --coverage` 或 `npx vitest --coverage` 获取覆盖率报告
- 识别覆盖率 < 80% 的文件，优先生成这些文件的测试

### 测试模式学习
- 分析现有测试文件的模式（setup、mock、assertion 风格）
- 新生成的测试遵循项目已有模式
```

- [ ] **Step 3: Commit**

```bash
git add skills/test-generator/SKILL.md
git commit -m "feat: enhance test-generator with coverage analysis and pattern learning"
```

---

### Task 8: 增强 refactor skill

**Files:**
- Modify: `skills/refactor/SKILL.md`

- [ ] **Step 1: 读取现有 skill**

Read: `skills/refactor/SKILL.md`

- [ ] **Step 2: 增强内容**

增加以下能力：

```markdown
## 重构影响分析

### 依赖图生成
- 使用 LSP 分析目标函数/类的调用者和被调用者
- 生成依赖关系图，识别重构影响范围

### 风险评估
- 标记被 3+ 个其他模块引用的函数为"高风险"
- 高风险重构前生成测试快照

### 重构模式推荐
- 根据代码坏味道推荐具体重构手法：
  - 长函数 → 提取函数
  - 大类 → 提取类
  - 重复代码 → 提取公共函数
  - 深层嵌套 → 卫语句/提前返回
```

- [ ] **Step 3: Commit**

```bash
git add skills/refactor/SKILL.md
git commit -m "feat: enhance refactor skill with dependency analysis and risk assessment"
```

---

### Task 9: 创建 CLAUDE.md 项目指引

**Files:**
- Create: `CLAUDE.md`

- [ ] **Step 1: 创建 CLAUDE.md**

Write to: `CLAUDE.md`

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: add CLAUDE.md plugin development guide"
```

---

### Task 10: 更新 README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: 读取现有 README**

Read: `README.md`

- [ ] **Step 2: 补充 hooks 和安装说明**

在现有内容基础上，添加 hooks 使用说明和安装指南。

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: update README with hooks and installation guide"
```

---

### Task 11: 最终验证

**Files:**
- None (verification only)

- [ ] **Step 1: 验证目录结构**

Run: `find . -type f -name "*.json" -o -name "*.sh" -o -name "*.md" | sort`

- [ ] **Step 2: 验证所有脚本有执行权限**

Run: `ls -la hooks/scripts/`
Expected: 所有 .sh 文件有 x 权限

- [ ] **Step 3: 运行 pre-commit 检查测试**

Run: `CLAUDE_PLUGIN_ROOT=. bash hooks/scripts/pre-commit-check.sh`
Expected: 检查通过，退出码 0

- [ ] **Step 4: 集成 smoke test**

Run: `claude --plugin-dir . --print "hello" 2>&1 | head -20`
Expected: 插件加载成功，hooks 被注册

- [ ] **Step 5: Final Commit**

```bash
git add -A
git commit -m "feat: complete plugin with hooks, marketplace, and enhanced skills"
```

---

## 完成

所有任务完成后，插件将包含：

1. ✅ 3 个修复后的 hooks（sed 兼容、路径正确、正则精确）
2. ✅ 市场配置文件
3. ✅ 项目指引文档
4. ✅ 3 个增强的核心 skills（code-review、test-generator、refactor）
5. ✅ 更新的 README

团队成员可以通过以下命令安装：

```bash
/plugin marketplace add https://github.com/hswyxj/claude-plugin-template
/plugin install team-toolkit@team-plugins
```

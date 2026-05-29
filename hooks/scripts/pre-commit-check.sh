#!/bin/bash
# Pre-commit Hook: 代码质量检查
# 用途：提交前检查暂存文件的代码质量

set -euo pipefail

# 从脚本位置推导插件根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$SCRIPT_DIR")")}"

ERRORS=0

echo "[Pre-commit] 开始代码质量检查..."

# 只检查暂存文件，而非全树
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

# 3. 检查敏感信息硬编码（缩窄正则为赋值模式）
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

#!/bin/bash
# Pre-tool Hook: 高风险操作安全拦截
# 用途：对高风险工具调用进行拦截

set -euo pipefail

# 从环境变量获取工具信息
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

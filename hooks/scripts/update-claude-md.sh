#!/bin/bash
# Stop Hook: 自动更新 CLAUDE.md
# 用途：会话结束时检查并更新 CLAUDE.md 中的项目信息

set -euo pipefail

# 从脚本位置推导插件根目录
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

# 显式检查空值
if [ -z "$LAST_UPDATE" ]; then
    echo "[Stop Hook] CLAUDE.md 中未找到日期标记，跳过更新"
    exit 0
fi

if [ "$LAST_UPDATE" = "$CURRENT_DATE" ]; then
    echo "[Stop Hook] CLAUDE.md 已是最新，跳过更新"
    exit 0
fi

# macOS 兼容性 - 用 sed -i.bak + rm
sed -i.bak "s/最后更新: [0-9-]*/最后更新: $CURRENT_DATE/" "$CLAUDE_MD"
rm -f "$CLAUDE_MD.bak"
echo "[Stop Hook] 已更新 CLAUDE.md 日期为 $CURRENT_DATE"

exit 0

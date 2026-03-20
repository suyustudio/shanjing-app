#!/bin/bash
# ================================================================
# M5 成就系统 Product 修复验证脚本
# ================================================================

echo "🔍 M5 Achievement Product Fix Verification"
echo "=========================================="

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✅${NC} $2"
        return 0
    else
        echo -e "${RED}❌${NC} $2 (文件不存在: $1)"
        return 1
    fi
}

check_content() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✅${NC} $3"
        return 0
    else
        echo -e "${RED}❌${NC} $3 (未找到: $2)"
        return 1
    fi
}

echo ""
echo "📁 文件检查"
echo "-----------"

# 后端文件
check_file "shanjing-api/prisma/seed_achievements.sql" "成就种子数据"
check_file "shanjing-api/src/modules/achievements/achievements-checker.service.ts" "成就检查服务"
check_file "shanjing-api/prisma/migrations/20250321000000_achievement_product_fix/migration.sql" "数据库迁移"

echo ""
echo "📱 前端文件"
echo "-----------"

# 前端文件
check_file "lib/widgets/achievement_share_poster.dart" "成就分享海报"
check_file "lib/services/analytics_service.dart" "数据埋点服务"
check_file "lib/services/achievement_websocket_service.dart" "WebSocket服务"
check_file "lib/screens/achievements/achievement_screen.dart" "成就页面"

echo ""
echo "🔍 关键内容检查"
echo "---------------"

# P0-2: 连续天数
check_content "shanjing-api/prisma/schema.prisma" "currentStreak" "Schema: currentStreak 字段"
check_content "shanjing-api/src/modules/achievements/achievements-checker.service.ts" "currentStreak" "Checker: 连续天数逻辑"

# P0-3: 点赞数
check_content "shanjing-api/prisma/schema.prisma" "totalLikesReceived" "Schema: totalLikesReceived 字段"
check_content "shanjing-api/src/modules/achievements/achievements-checker.service.ts" "updateLikesCount" "Checker: 点赞数更新"

# P1-2: 首次徒步
check_content "shanjing-api/src/modules/achievements/achievements-checker.service.ts" "checkAndUnlockFirstHike" "Checker: 首次徒步成就"

# P1-4: WebSocket 重连
check_content "lib/services/achievement_websocket_service.dart" "_scheduleReconnect" "WebSocket: 重连机制"
check_content "lib/services/achievement_websocket_service.dart" "_maxReconnectAttempts" "WebSocket: 最大重试次数"

# P1-5: 离线同步
check_content "lib/services/achievement_websocket_service.dart" "PendingAchievementUnlock" "WebSocket: 离线事件模型"
check_content "lib/services/achievement_websocket_service.dart" "_syncPendingUnlocks" "WebSocket: 同步方法"

# P2-1: 4列网格
check_content "lib/screens/achievements/achievement_screen.dart" "crossAxisCount: 4" "UI: 4列网格布局"

echo ""
echo "📊 成就数据检查"
echo "---------------"

# 检查种子数据中的成就数量
if [ -f "shanjing-api/prisma/seed_achievements.sql" ]; then
    ACHIEVEMENT_COUNT=$(grep -c "INSERT INTO achievements" shanjing-api/prisma/seed_achievements.sql)
    LEVEL_COUNT=$(grep -c "INSERT INTO achievement_levels" shanjing-api/prisma/seed_achievements.sql)
    
    echo "成就定义数量: $ACHIEVEMENT_COUNT"
    echo "成就等级数量: $LEVEL_COUNT"
    
    if [ "$ACHIEVEMENT_COUNT" -eq 5 ] && [ "$LEVEL_COUNT" -eq 20 ]; then
        echo -e "${GREEN}✅${NC} 成就数据符合 PRD (5类 × 4级 = 20个)"
    else
        echo -e "${YELLOW}⚠️${NC} 成就数据可能需要检查 (期望: 5类, 20级)"
    fi
fi

echo ""
echo "=========================================="
echo "验证完成！"
echo ""
echo "下一步操作:"
echo "1. 运行数据库迁移: npx prisma migrate dev"
echo "2. 导入种子数据: npx prisma db seed"
echo "3. 启动后端服务: npm run start:dev"
echo "4. 运行前端应用: flutter run"

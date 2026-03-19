#!/bin/bash
# qa/m4/p2_testing/automation/scripts/run_smoke.sh
# 烟雾测试快速运行脚本

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "${GREEN}========================================${NC}"
echo "${GREEN}  山径APP 烟雾测试${NC}"
echo "${GREEN}========================================${NC}"
echo ""

# 检查Flutter
if ! command -v flutter &> /dev/null; then
    echo "${RED}错误: 未找到Flutter${NC}"
    exit 1
fi

# 获取依赖
echo "${YELLOW}正在获取依赖...${NC}"
flutter pub get

# 运行烟雾测试
echo "${YELLOW}运行烟雾测试...${NC}"
flutter test qa/m4/p2_testing/automation/e2e/regressions/smoke_test.dart \
    --reporter expanded

echo ""
echo "${GREEN}========================================${NC}"
echo "${GREEN}  烟雾测试完成${NC}"
echo "${GREEN}========================================${NC}"

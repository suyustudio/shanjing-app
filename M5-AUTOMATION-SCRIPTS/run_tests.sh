#!/bin/bash
# M5 自动化测试执行脚本
# Usage: ./run_m5_tests.sh [module] [options]

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 帮助信息
show_help() {
    echo "M5 自动化测试执行脚本"
    echo ""
    echo "Usage: $0 [module] [options]"
    echo ""
    echo "Modules:"
    echo "  onboarding      新手引导测试"
    echo "  achievement     成就系统测试"
    echo "  recommendation  推荐算法测试"
    echo "  regression      M4回归测试"
    echo "  all             全部测试"
    echo ""
    echo "Options:"
    echo "  --device ID     指定设备ID"
    echo "  --coverage      生成覆盖率报告"
    echo "  --profile       使用profile模式"
    echo "  --help          显示帮助"
    echo ""
    echo "Examples:"
    echo "  $0 onboarding              # 运行新手引导测试"
    echo "  $0 all --coverage          # 运行全部测试并生成覆盖率报告"
    echo "  $0 achievement --device    # 在指定设备上运行成就测试"
}

# 参数解析
MODULE=""
DEVICE=""
COVERAGE=false
PROFILE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        onboarding|achievement|recommendation|regression|all)
            MODULE=$1
            shift
            ;;
        --device)
            DEVICE="$2"
            shift 2
            ;;
        --coverage)
            COVERAGE=true
            shift
            ;;
        --profile)
            PROFILE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}未知参数: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

if [ -z "$MODULE" ]; then
    echo -e "${RED}错误: 请指定测试模块${NC}"
    show_help
    exit 1
fi

# 检查Flutter环境
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        echo -e "${RED}错误: Flutter未安装${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Flutter版本: $(flutter --version | head -1)${NC}"
}

# 获取测试文件路径
get_test_file() {
    case $1 in
        onboarding)
            echo "M5-AUTOMATION-SCRIPTS/onboarding/onboarding_test.dart"
            ;;
        achievement)
            echo "M5-AUTOMATION-SCRIPTS/achievement/achievement_test.dart"
            ;;
        recommendation)
            echo "M5-AUTOMATION-SCRIPTS/recommendation/recommendation_test.dart"
            ;;
        regression)
            echo "M5-AUTOMATION-SCRIPTS/regression/m4_regression_test.dart"
            ;;
        all)
            echo "M5-AUTOMATION-SCRIPTS/"
            ;;
    esac
}

# 运行测试
run_test() {
    local test_file=$(get_test_file $1)
    local device_arg=""
    local coverage_arg=""
    local mode_arg=""
    
    if [ -n "$DEVICE" ]; then
        device_arg="-d $DEVICE"
    fi
    
    if [ "$COVERAGE" = true ]; then
        coverage_arg="--coverage"
    fi
    
    if [ "$PROFILE" = true ]; then
        mode_arg="--profile"
    fi
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}运行: $1 测试${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    if [ "$1" = "all" ]; then
        flutter test $test_file $device_arg $coverage_arg $mode_arg
    else
        flutter test $test_file $device_arg $coverage_arg $mode_arg --reporter expanded
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $1 测试通过${NC}"
    else
        echo -e "${RED}✗ $1 测试失败${NC}"
        return 1
    fi
}

# 生成测试报告
generate_report() {
    if [ "$COVERAGE" = true ]; then
        echo -e "${BLUE}生成覆盖率报告...${NC}"
        genhtml coverage/lcov.info -o coverage/html
        echo -e "${GREEN}覆盖率报告: coverage/html/index.html${NC}"
    fi
    
    # 生成测试摘要
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}测试执行摘要${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo "模块: $MODULE"
    echo "设备: ${DEVICE:-默认}"
    echo "覆盖率: $COVERAGE"
    echo "Profile模式: $PROFILE"
    echo "时间: $(date)"
}

# 主函数
main() {
    echo -e "${BLUE}M5 自动化测试执行${NC}"
    echo ""
    
    check_flutter
    
    # 确保在项目根目录
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}错误: 请在项目根目录运行此脚本${NC}"
        exit 1
    fi
    
    # 运行测试
    if [ "$MODULE" = "all" ]; then
        run_test "onboarding" || exit 1
        run_test "achievement" || exit 1
        run_test "recommendation" || exit 1
        run_test "regression" || exit 1
    else
        run_test "$MODULE" || exit 1
    fi
    
    generate_report
    
    echo ""
    echo -e "${GREEN}✓ 测试执行完成${NC}"
}

# 执行
main

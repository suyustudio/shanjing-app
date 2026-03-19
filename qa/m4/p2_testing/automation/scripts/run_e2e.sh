#!/bin/bash
# qa/m4/p2_testing/automation/scripts/run_e2e.sh
# E2E测试运行脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 配置
TEST_DIR="qa/m4/p2_testing/automation/e2e"
DEVICE_ID=""
REPORTER="expanded"
FLOW=""
VERBOSE=false

# 打印帮助
print_help() {
    echo "山径APP E2E测试脚本"
    echo ""
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -d, --device-id ID    指定测试设备ID"
    echo "  -f, --flow NAME       指定测试流程 (auth, navigation, sos, offline, share)"
    echo "  -r, --reporter TYPE   指定报告类型 (expanded, compact, json)"
    echo "  -v, --verbose         详细输出"
    echo "  -h, --help            显示帮助"
    echo ""
    echo "示例:"
    echo "  $0                                    # 运行全部E2E测试"
    echo "  $0 -f auth                            # 运行认证流程测试"
    echo "  $0 -d emulator-5554                   # 在指定设备上运行"
    echo "  $0 -f navigation -r json              # 以JSON格式输出导航测试"
}

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--device-id)
            DEVICE_ID="$2"
            shift 2
            ;;
        -f|--flow)
            FLOW="$2"
            shift 2
            ;;
        -r|--reporter)
            REPORTER="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            print_help
            exit 0
            ;;
        *)
            echo "${RED}错误: 未知参数 $1${NC}"
            print_help
            exit 1
            ;;
    esac
done

# 检查Flutter环境
check_flutter() {
    if ! command -v flutter &> /dev/null; then
        echo "${RED}错误: 未找到Flutter${NC}"
        echo "请先安装Flutter SDK: https://flutter.dev/docs/get-started/install"
        exit 1
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo "Flutter版本:"
        flutter --version
    fi
}

# 获取依赖
get_dependencies() {
    echo "${YELLOW}正在获取依赖...${NC}"
    flutter pub get
    if [ $? -eq 0 ]; then
        echo "${GREEN}依赖获取成功${NC}"
    else
        echo "${RED}依赖获取失败${NC}"
        exit 1
    fi
}

# 运行测试
run_tests() {
    local build_args=""
    if [ -n "$DEVICE_ID" ]; then
        build_args="--device-id $DEVICE_ID"
    fi
    
    if [ -n "$FLOW" ]; then
        echo "${YELLOW}运行测试流程: $FLOW${NC}"
        local test_file="$TEST_DIR/flows/${FLOW}_flow_test.dart"
        
        if [ ! -f "$test_file" ]; then
            echo "${RED}错误: 测试文件不存在: $test_file${NC}"
            echo "可用流程: auth, navigation, sos, offline, share"
            exit 1
        fi
        
        flutter test "$test_file" \
            --reporter "$REPORTER" \
            $build_args
    else
        echo "${YELLOW}运行全部E2E测试...${NC}"
        flutter test "$TEST_DIR/" \
            --reporter "$REPORTER" \
            $build_args
    fi
}

# 主函数
main() {
    echo "${GREEN}========================================${NC}"
    echo "${GREEN}  山径APP E2E测试${NC}"
    echo "${GREEN}========================================${NC}"
    echo ""
    
    check_flutter
    get_dependencies
    run_tests
    
    echo ""
    echo "${GREEN}========================================${NC}"
    echo "${GREEN}  E2E测试完成${NC}"
    echo "${GREEN}========================================${NC}"
}

main

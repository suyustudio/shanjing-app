#!/bin/bash

# 山径APP - 轨迹数据 ADB 提取脚本
# 使用方法：./adb_extract.sh [输出目录]
# 默认输出目录：./exported_trails_$(date +%Y%m%d_%H%M%S)

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 应用包名和路径
APP_PACKAGE="com.suyustudio.shanjing"
PRIVATE_PATH="/data/data/${APP_PACKAGE}/app_flutter/recordings_export"
PUBLIC_PATH="/storage/emulated/0/Download"

# 输出目录
if [ $# -eq 0 ]; then
    OUTPUT_DIR="./exported_trails_$(date +%Y%m%d_%H%M%S)"
else
    OUTPUT_DIR="$1"
fi

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 ADB 连接
check_adb() {
    log_info "检查 ADB 连接..."
    
    if ! command -v adb &> /dev/null; then
        log_error "ADB 未安装，请先安装 Android SDK Platform Tools"
        exit 1
    fi
    
    # 检查设备连接
    DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)
    if [ "$DEVICES" -eq 0 ]; then
        log_error "未检测到连接的 Android 设备"
        echo "请确保："
        echo "1. 手机已开启 USB 调试（开发者选项 → USB 调试）"
        echo "2. USB 线已连接"
        echo "3. 手机上点击'允许调试'"
        exit 1
    fi
    
    log_success "检测到 $(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l) 台设备"
}

# 检查文件存储位置
check_storage_locations() {
    log_info "检查文件存储位置..."
    
    LOCATIONS_FOUND=0
    
    # 检查私有存储
    if adb shell "ls $PRIVATE_PATH" 2>/dev/null | grep -q "."; then
        log_success "找到私有存储路径: $PRIVATE_PATH"
        PRIVATE_FILES=$(adb shell "find $PRIVATE_PATH -name '*.gpx' -o -name '*.json' 2>/dev/null" | wc -l)
        log_info "私有存储中找到 $PRIVATE_FILES 个文件"
        LOCATIONS_FOUND=$((LOCATIONS_FOUND + 1))
    else
        log_warning "私有存储路径不存在或为空: $PRIVATE_PATH"
    fi
    
    # 检查公共存储
    if adb shell "ls $PUBLIC_PATH" 2>/dev/null | grep -q "."; then
        log_success "找到公共存储路径: $PUBLIC_PATH"
        PUBLIC_FILES=$(adb shell "find $PUBLIC_PATH -name '*.gpx' -o -name '*.json' 2>/dev/null" | wc -l)
        log_info "公共存储中找到 $PUBLIC_FILES 个文件"
        LOCATIONS_FOUND=$((LOCATIONS_FOUND + 1))
    else
        log_warning "公共存储路径不存在或为空: $PUBLIC_PATH"
    fi
    
    if [ $LOCATIONS_FOUND -eq 0 ]; then
        log_error "未找到任何轨迹文件"
        echo "可能原因："
        echo "1. 尚未采集任何轨迹数据"
        echo "2. 文件存储在其他位置"
        echo "3. 存储权限未授予"
        exit 1
    fi
}

# 创建输出目录
create_output_dir() {
    log_info "创建输出目录: $OUTPUT_DIR"
    
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR/gpx"
    mkdir -p "$OUTPUT_DIR/json"
    mkdir -p "$OUTPUT_DIR/raw"
    
    log_success "输出目录结构创建完成"
}

# 从私有存储提取文件
extract_from_private() {
    log_info "从私有存储提取文件..."
    
    # 获取文件列表
    FILES=$(adb shell "find $PRIVATE_PATH -name '*.gpx' -o -name '*.json' 2>/dev/null" || true)
    
    if [ -z "$FILES" ]; then
        log_warning "私有存储中没有找到文件"
        return 0
    fi
    
    COUNT=0
    for FILE in $FILES; do
        # 清理文件名中的换行符
        FILE=$(echo "$FILE" | tr -d '\r\n')
        
        # 提取文件名
        FILENAME=$(basename "$FILE")
        
        # 确定文件类型
        if [[ "$FILENAME" == *.gpx ]]; then
            DEST_DIR="$OUTPUT_DIR/gpx"
        elif [[ "$FILENAME" == *.json ]]; then
            DEST_DIR="$OUTPUT_DIR/json"
        else
            DEST_DIR="$OUTPUT_DIR/raw"
        fi
        
        # 提取文件
        log_info "提取: $FILENAME"
        adb pull "$FILE" "$DEST_DIR/" 2>/dev/null || {
            log_warning "提取失败: $FILENAME"
            continue
        }
        
        COUNT=$((COUNT + 1))
    done
    
    log_success "从私有存储提取了 $COUNT 个文件"
}

# 从公共存储提取文件
extract_from_public() {
    log_info "从公共存储提取文件..."
    
    # 获取文件列表
    FILES=$(adb shell "find $PUBLIC_PATH -name '*.gpx' -o -name '*.json' 2>/dev/null" || true)
    
    if [ -z "$FILES" ]; then
        log_warning "公共存储中没有找到文件"
        return 0
    fi
    
    COUNT=0
    for FILE in $FILES; do
        # 清理文件名中的换行符
        FILE=$(echo "$FILE" | tr -d '\r\n')
        
        # 检查是否是山径APP的文件（根据命名模式）
        if ! echo "$FILE" | grep -q "山径\|shanjiang\|trail"; then
            # 检查文件名是否匹配模式：*_YYYY-MM-DD_*.gpx
            if ! echo "$FILE" | grep -q -E ".*_[0-9]{4}-[0-9]{2}-[0-9]{2}_.*\\.(gpx|json)"; then
                continue
            fi
        fi
        
        # 提取文件名
        FILENAME=$(basename "$FILE")
        
        # 确定文件类型
        if [[ "$FILENAME" == *.gpx ]]; then
            DEST_DIR="$OUTPUT_DIR/gpx"
        elif [[ "$FILENAME" == *.json ]]; then
            DEST_DIR="$OUTPUT_DIR/json"
        else
            DEST_DIR="$OUTPUT_DIR/raw"
        fi
        
        # 检查是否已存在（避免重复）
        if [ -f "$DEST_DIR/$FILENAME" ]; then
            log_info "文件已存在，跳过: $FILENAME"
            continue
        fi
        
        # 提取文件
        log_info "提取: $FILENAME"
        adb pull "$FILE" "$DEST_DIR/" 2>/dev/null || {
            log_warning "提取失败: $FILENAME"
            continue
        }
        
        COUNT=$((COUNT + 1))
    done
    
    log_success "从公共存储提取了 $COUNT 个文件"
}

# 生成索引文件
generate_index() {
    log_info "生成索引文件..."
    
    # HTML 索引
    cat > "$OUTPUT_DIR/index.html" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>山径APP - 轨迹数据导出</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f5;
        }
        header {
            background: linear-gradient(135deg, #4CAF50, #2196F3);
            color: white;
            padding: 30px;
            border-radius: 10px;
            margin-bottom: 30px;
        }
        h1 {
            margin: 0;
            font-size: 2.5em;
        }
        .stats {
            display: flex;
            gap: 20px;
            margin: 20px 0;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            flex: 1;
        }
        .file-list {
            background: white;
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #eee;
        }
        th {
            background: #f8f9fa;
        }
        .gpx-file { color: #4CAF50; }
        .json-file { color: #2196F3; }
        .download-btn {
            background: #4CAF50;
            color: white;
            border: none;
            padding: 6px 12px;
            border-radius: 4px;
            text-decoration: none;
            font-size: 14px;
            cursor: pointer;
        }
        .timestamp {
            color: #666;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <header>
        <h1>📡 山径APP - 轨迹数据导出</h1>
        <p class="timestamp">导出时间: $(date '+%Y-%m-%d %H:%M:%S')</p>
    </header>
    
    <div class="stats">
        <div class="stat-card">
            <h3>📊 统计信息</h3>
            <p>GPX 文件: <span id="gpx-count">0</span></p>
            <p>JSON 文件: <span id="json-count">0</span></p>
            <p>总文件数: <span id="total-count">0</span></p>
        </div>
        <div class="stat-card">
            <h3>📂 目录结构</h3>
            <p><a href="gpx/">📁 gpx/</a> - GPX 格式轨迹</p>
            <p><a href="json/">📁 json/</a> - JSON 原始数据</p>
            <p><a href="raw/">📁 raw/</a> - 其他格式</p>
        </div>
    </div>
    
    <div class="file-list">
        <h2>📄 文件列表</h2>
        <table id="file-table">
            <thead>
                <tr>
                    <th>文件名</th>
                    <th>类型</th>
                    <th>大小</th>
                    <th>修改时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <!-- 文件列表将通过 JavaScript 动态生成 -->
            </tbody>
        </table>
    </div>
    
    <script>
        // 统计文件
        async function countFiles() {
            try {
                const [gpxFiles, jsonFiles] = await Promise.all([
                    fetch('gpx/').then(r => r.text()),
                    fetch('json/').then(r => r.text())
                ]);
                
                // 简单的文件计数（根据链接数）
                const gpxCount = (gpxFiles.match(/<a href="/g) || []).length - 2; // 减去父目录链接
                const jsonCount = (jsonFiles.match(/<a href="/g) || []).length - 2;
                
                document.getElementById('gpx-count').textContent = gpxCount;
                document.getElementById('json-count').textContent = jsonCount;
                document.getElementById('total-count').textContent = gpxCount + jsonCount;
                
                return { gpxCount, jsonCount };
            } catch (error) {
                console.error('统计文件失败:', error);
                return { gpxCount: 0, jsonCount: 0 };
            }
        }
        
        // 加载文件列表
        async function loadFileList() {
            const tbody = document.querySelector('#file-table tbody');
            
            // 添加 GPX 文件
            const gpxFiles = await getFileList('gpx/');
            gpxFiles.forEach(file => {
                addFileRow(file, 'GPX', 'gpx/');
            });
            
            // 添加 JSON 文件
            const jsonFiles = await getFileList('json/');
            jsonFiles.forEach(file => {
                addFileRow(file, 'JSON', 'json/');
            });
        }
        
        // 获取目录文件列表
        async function getFileList(dir) {
            try {
                const response = await fetch(dir);
                const html = await response.text();
                
                // 简单的 HTML 解析（提取文件名）
                const parser = new DOMParser();
                const doc = parser.parseFromString(html, 'text/html');
                const links = doc.querySelectorAll('a[href]');
                
                const files = [];
                links.forEach(link => {
                    const href = link.getAttribute('href');
                    if (href && !href.startsWith('?') && !href.startsWith('/') && 
                        href !== '../' && !href.includes('?')) {
                        files.push(href);
                    }
                });
                
                return files;
            } catch (error) {
                console.error(`读取目录失败: ${dir}`, error);
                return [];
            }
        }
        
        // 添加文件行
        function addFileRow(filename, type, dir) {
            const tbody = document.querySelector('#file-table tbody');
            const row = document.createElement('tr');
            
            const className = type === 'GPX' ? 'gpx-file' : 'json-file';
            
            row.innerHTML = \`
                <td class="\${className}">\${filename}</td>
                <td><span class="badge">\${type}</span></td>
                <td>--</td>
                <td>--</td>
                <td><a href="\${dir}\${filename}" class="download-btn" download>下载</a></td>
            \`;
            
            tbody.appendChild(row);
        }
        
        // 初始化
        document.addEventListener('DOMContentLoaded', () => {
            countFiles();
            loadFileList();
        });
    </script>
</body>
</html>
EOF
    
    # 生成文本索引
    cat > "$OUTPUT_DIR/INDEX.md" << EOF
# 山径APP - 轨迹数据导出索引

## 导出信息
- **导出时间**: $(date '+%Y-%m-%d %H:%M:%S')
- **输出目录**: $(pwd)/$OUTPUT_DIR
- **设备信息**: $(adb shell "getprop ro.product.model" 2>/dev/null || echo "未知")

## 文件统计
\`\`\`
GPX 文件: $(find "$OUTPUT_DIR/gpx" -name "*.gpx" 2>/dev/null | wc -l)
JSON 文件: $(find "$OUTPUT_DIR/json" -name "*.json" 2>/dev/null | wc -l)
其他文件: $(find "$OUTPUT_DIR/raw" -type f 2>/dev/null | wc -l)
\`\`\`

## GPX 文件列表
\`\`\`
$(find "$OUTPUT_DIR/gpx" -name "*.gpx" -exec basename {} \; 2>/dev/null | sort)
\`\`\`

## JSON 文件列表
\`\`\`
$(find "$OUTPUT_DIR/json" -name "*.json" -exec basename {} \; 2>/dev/null | sort)
\`\`\`

## 使用说明
1. **GPX 文件**: 通用 GPS 轨迹格式，可在 Google Earth、两步路、六只脚等软件中打开
2. **JSON 文件**: 原始数据格式，包含完整录制信息
3. **数据验证**: 建议用文本编辑器打开一个 GPX 文件，确认数据完整

## 快速命令
\`\`\`bash
# 查看目录
ls -la $OUTPUT_DIR/

# 查看 GPX 文件内容
head -20 $OUTPUT_DIR/gpx/*.gpx

# 批量转换（如果需要）
for f in $OUTPUT_DIR/gpx/*.gpx; do
    echo "处理: \$(basename \$f)"
done
\`\`\`
EOF
    
    log_success "索引文件生成完成"
    log_info "HTML 索引: $OUTPUT_DIR/index.html"
    log_info "文本索引: $OUTPUT_DIR/INDEX.md"
}

# 显示总结
show_summary() {
    log_success "✅ ADB 提取完成！"
    echo ""
    echo "📊 提取统计:"
    echo "  - GPX 文件: $(find "$OUTPUT_DIR/gpx" -name "*.gpx" 2>/dev/null | wc -l)"
    echo "  - JSON 文件: $(find "$OUTPUT_DIR/json" -name "*.json" 2>/dev/null | wc -l)"
    echo "  - 总文件数: $(find "$OUTPUT_DIR" -type f 2>/dev/null | wc -l)"
    echo ""
    echo "📁 输出目录: $OUTPUT_DIR"
    echo "  ├── gpx/     - GPX 格式轨迹"
    echo "  ├── json/    - JSON 原始数据"
    echo "  ├── raw/     - 其他格式"
    echo "  ├── index.html - 网页索引"
    echo "  └── INDEX.md   - 文本索引"
    echo ""
    echo "🔗 快速访问:"
    echo "  file://$(pwd)/$OUTPUT_DIR/index.html"
    echo ""
    echo "💡 提示:"
    echo "  1. 将手机连接到电脑，开启 USB 调试"
    echo "  2. 再次运行此脚本可提取新文件"
    echo "  3. 查看 INDEX.md 获取详细文件列表"
}

# 主函数
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}    山径APP - 轨迹数据 ADB 提取工具${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    
    # 执行步骤
    check_adb
    check_storage_locations
    create_output_dir
    extract_from_private
    extract_from_public
    generate_index
    show_summary
    
    echo -e "${GREEN}✅ 所有操作完成！${NC}"
}

# 捕获中断信号
trap 'log_error "用户中断"; exit 1' INT

# 运行主函数
main "$@"
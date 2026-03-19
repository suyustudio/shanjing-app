#!/usr/bin/env python3
"""设计地图路线标记图标"""
from PIL import Image, ImageDraw, ImageFont
import os

# 创建目录
os.makedirs('assets/markers', exist_ok=True)

# 分辨率定义
resolutions = {
    'mdpi': 24,
    'hdpi': 36,
    'xhdpi': 48,
    'xxhdpi': 72,
    'xxxhdpi': 96
}

# 颜色定义 - 户外徒步主题
colors = {
    'start': {
        'primary': '#22C55E',      # 鲜艳绿色
        'secondary': '#16A34A',    # 深绿色
        'accent': '#86EFAC',       # 浅绿色高光
        'shadow': '#15803D'        # 阴影色
    },
    'end': {
        'primary': '#EF4444',      # 鲜艳红色
        'secondary': '#DC2626',    # 深红色
        'accent': '#FCA5A5',       # 浅红色高光
        'shadow': '#B91C1C'        # 阴影色
    },
    'loop': {
        'primary': '#F97316',      # 鲜艳橙色
        'secondary': '#EA580C',    # 深橙色
        'accent': '#FDBA74',       # 浅橙色高光
        'shadow': '#C2410C'        # 阴影色
    }
}

def hex_to_rgba(hex_color, alpha=255):
    """将hex颜色转换为RGBA"""
    hex_color = hex_color.lstrip('#')
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4)) + (alpha,)

def create_start_marker(size):
    """创建起点标记 - 绿色定位针形状，带S字母"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    c = colors['start']
    margin = size // 12
    
    # 绘制定位针形状
    pin_width = size - margin * 2
    pin_height = size - margin * 2
    
    # 主体 - 上半圆
    circle_y = margin + pin_width // 2
    radius = pin_width // 2 - 1
    
    # 阴影
    shadow_offset = max(1, size // 24)
    draw.ellipse(
        [margin + shadow_offset, margin + shadow_offset, 
         margin + pin_width + shadow_offset, margin + pin_width + shadow_offset],
        fill=hex_to_rgba(c['shadow'], 80)
    )
    
    # 主体圆
    draw.ellipse(
        [margin, margin, margin + pin_width, margin + pin_width],
        fill=hex_to_rgba(c['primary']),
        outline=hex_to_rgba(c['secondary']),
        width=max(1, size // 24)
    )
    
    # 高光
    highlight_margin = size // 6
    draw.ellipse(
        [margin + highlight_margin, margin + highlight_margin // 2,
         margin + highlight_margin + radius, margin + highlight_margin // 2 + radius // 2],
        fill=hex_to_rgba(c['accent'], 120)
    )
    
    # 绘制S字母
    font_size = int(size * 0.5)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except:
        font = ImageFont.load_default()
    
    # 获取文字尺寸
    bbox = draw.textbbox((0, 0), "S", font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    
    text_x = (size - text_w) // 2
    text_y = (size - pin_width // 2 - text_h) // 2 + bbox[1]
    
    # 文字阴影
    draw.text((text_x + 1, text_y + 1), "S", font=font, fill=hex_to_rgba(c['shadow']))
    # 文字
    draw.text((text_x, text_y), "S", font=font, fill=(255, 255, 255, 255))
    
    return img

def create_end_marker(size):
    """创建终点标记 - 红色定位针形状，带E字母"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    c = colors['end']
    margin = size // 12
    
    # 主体 - 菱形/方形带圆角
    pin_width = size - margin * 2
    
    # 阴影
    shadow_offset = max(1, size // 24)
    draw.rounded_rectangle(
        [margin + shadow_offset, margin + shadow_offset, 
         margin + pin_width + shadow_offset, margin + pin_width + shadow_offset],
        radius=size // 6,
        fill=hex_to_rgba(c['shadow'], 80)
    )
    
    # 主体
    draw.rounded_rectangle(
        [margin, margin, margin + pin_width, margin + pin_width],
        radius=size // 6,
        fill=hex_to_rgba(c['primary']),
        outline=hex_to_rgba(c['secondary']),
        width=max(1, size // 24)
    )
    
    # 高光
    highlight_margin = size // 5
    draw.arc(
        [margin + highlight_margin, margin + highlight_margin // 2,
         margin + pin_width - highlight_margin, margin + pin_width // 2],
        start=0, end=180,
        fill=hex_to_rgba(c['accent'], 150),
        width=max(1, size // 20)
    )
    
    # 绘制E字母
    font_size = int(size * 0.5)
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except:
        font = ImageFont.load_default()
    
    bbox = draw.textbbox((0, 0), "E", font=font)
    text_w = bbox[2] - bbox[0]
    text_h = bbox[3] - bbox[1]
    
    text_x = (size - text_w) // 2
    text_y = (size - text_h) // 2 + bbox[1]
    
    # 文字阴影
    draw.text((text_x + 1, text_y + 1), "E", font=font, fill=hex_to_rgba(c['shadow']))
    # 文字
    draw.text((text_x, text_y), "E", font=font, fill=(255, 255, 255, 255))
    
    return img

def create_loop_marker(size):
    """创建环形路线标记 - 橙色圆形带循环箭头"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    c = colors['loop']
    margin = size // 12
    
    # 主体圆
    circle_size = size - margin * 2
    
    # 阴影
    shadow_offset = max(1, size // 24)
    draw.ellipse(
        [margin + shadow_offset, margin + shadow_offset, 
         margin + circle_size + shadow_offset, margin + circle_size + shadow_offset],
        fill=hex_to_rgba(c['shadow'], 80)
    )
    
    # 外圈 - 圆环效果
    draw.ellipse(
        [margin, margin, margin + circle_size, margin + circle_size],
        fill=hex_to_rgba(c['primary']),
        outline=hex_to_rgba(c['secondary']),
        width=max(1, size // 24)
    )
    
    # 内圈高光
    inner_margin = size // 4
    draw.ellipse(
        [margin + inner_margin, margin + inner_margin,
         margin + circle_size - inner_margin, margin + circle_size - inner_margin],
        outline=hex_to_rgba(c['accent']),
        width=max(1, size // 20)
    )
    
    # 绘制循环箭头 ⟳
    center = size // 2
    radius = size // 3
    
    # 绘制弧形箭头
    arc_box = [center - radius, center - radius, center + radius, center + radius]
    
    # 绘制箭头弧线（大部分圆）
    draw.arc(arc_box, start=45, end=315, fill=(255, 255, 255, 255), width=max(2, size // 12))
    
    # 绘制箭头头部
    arrow_size = max(4, size // 6)
    # 箭头在315度位置（右下）
    angle = 315 * 3.14159 / 180
    arrow_x = center + radius * 0.85 * 0.707  # cos(315)
    arrow_y = center + radius * 0.85 * 0.707  # sin(315)
    
    # 简化的箭头绘制
    arrow_points = [
        (arrow_x, arrow_y),
        (arrow_x - arrow_size * 0.7, arrow_y - arrow_size),
        (arrow_x - arrow_size, arrow_y - arrow_size * 0.7)
    ]
    draw.polygon(arrow_points, fill=(255, 255, 255, 255))
    
    return img

def create_preview():
    """创建预览图展示所有设计"""
    # 预览画布大小
    preview_w = 800
    preview_h = 500
    
    img = Image.new('RGBA', (preview_w, preview_h), (245, 247, 250, 255))
    draw = ImageDraw.Draw(img)
    
    # 标题
    try:
        title_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 28)
        label_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
        desc_font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 12)
    except:
        title_font = ImageFont.load_default()
        label_font = ImageFont.load_default()
        desc_font = ImageFont.load_default()
    
    # 绘制标题
    title = "地图路线标记图标设计预览"
    draw.text((preview_w // 2 - 180, 30), title, font=title_font, fill=(51, 65, 85, 255))
    
    # 背景说明
    desc = "户外徒步主题 | 简洁现代风格 | 透明背景PNG"
    draw.text((preview_w // 2 - 120, 70), desc, font=desc_font, fill=(100, 116, 139, 255))
    
    # 三个主要展示区域
    marker_size = 96
    positions = [
        (150, 180, "起点", "Start", "#22C55E"),
        (350, 180, "终点", "End", "#EF4444"),
        (550, 180, "环形路线", "Loop", "#F97316")
    ]
    
    # 创建大图标
    start_large = create_start_marker(96)
    end_large = create_end_marker(96)
    loop_large = create_loop_marker(96)
    
    markers = [start_large, end_large, loop_large]
    
    for i, (x, y, cn_name, en_name, color) in enumerate(positions):
        # 绘制背景卡片
        card_margin = 20
        draw.rounded_rectangle(
            [x - card_margin, y - card_margin, x + marker_size + card_margin, y + marker_size + 80],
            radius=12,
            fill=(255, 255, 255, 255),
            outline=(226, 232, 240, 255),
            width=1
        )
        
        # 粘贴图标
        img.paste(markers[i], (x, y), markers[i])
        
        # 标签
        draw.text((x + marker_size // 2 - 30, y + marker_size + 15), cn_name, font=label_font, fill=(51, 65, 85, 255))
        draw.text((x + marker_size // 2 - 20, y + marker_size + 38), en_name, font=desc_font, fill=(100, 116, 139, 255))
    
    # 下方展示不同分辨率
    y_res = 380
    res_labels = ['mdpi\n24px', 'hdpi\n36px', 'xhdpi\n48px', 'xxhdpi\n72px', 'xxxhdpi\n96px']
    res_sizes = [24, 36, 48, 72, 96]
    
    # 绘制分辨率标签
    draw.text((50, y_res - 20), "分辨率适配:", font=label_font, fill=(51, 65, 85, 255))
    
    x_start = 100
    for i, (label, size) in enumerate(zip(res_labels, res_sizes)):
        x = x_start + i * 140
        
        # 创建对应尺寸的图标
        start_small = create_start_marker(size)
        
        # 居中显示
        icon_x = x + (100 - size) // 2
        img.paste(start_small, (icon_x, y_res), start_small)
        
        # 标签
        draw.text((x + 20, y_res + size + 10), label, font=desc_font, fill=(100, 116, 139, 255))
    
    # 保存预览图
    img.save('assets/markers/preview_design.png')
    print("✅ 预览图已保存: assets/markers/preview_design.png")
    
    return img

def export_all_icons():
    """导出所有分辨率的图标"""
    for name, size in resolutions.items():
        # 起点
        start = create_start_marker(size)
        start.save(f'assets/markers/ic_marker_start_{name}.png')
        
        # 终点
        end = create_end_marker(size)
        end.save(f'assets/markers/ic_marker_end_{name}.png')
        
        # 环形
        loop = create_loop_marker(size)
        loop.save(f'assets/markers/ic_marker_loop_{name}.png')
        
        print(f"✅ {name} ({size}x{size}) 图标已生成")

if __name__ == '__main__':
    print("🎨 正在设计地图标记图标...")
    print("-" * 40)
    
    # 生成预览图
    preview = create_preview()
    
    print("-" * 40)
    print("✅ 预览图生成完成!")
    print("\n📋 设计说明:")
    print("  • 起点标记: 绿色圆形定位针 + 'S'字母")
    print("  • 终点标记: 红色方形圆角 + 'E'字母")
    print("  • 环形标记: 橙色圆环 + 循环箭头⟳")
    print("  • 风格: 简洁现代，适合户外徒步场景")
    print("  • 特点: 阴影、高光、透明背景")
    print("\n💡 确认设计后，将生成所有分辨率的图标文件")

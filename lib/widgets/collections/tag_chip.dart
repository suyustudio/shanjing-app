// tag_chip.dart
// 山径APP - 标签芯片组件（M7 P1）
// 用于显示和管理收藏夹标签

import 'package:flutter/material.dart';

/// 标签芯片样式
enum TagChipStyle {
  normal,      // 普通样式
  outlined,    // 轮廓样式
  filled,      // 填充样式
  selectable,  // 可选择样式
  editable,    // 可编辑样式（带删除按钮）
}

/// 标签芯片组件
class TagChip extends StatelessWidget {
  final String tag;
  final TagChipStyle style;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color? color;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final bool showIcon;

  const TagChip({
    Key? key,
    required this.tag,
    this.style = TagChipStyle.normal,
    this.isSelected = false,
    this.onTap,
    this.onDelete,
    this.color,
    this.fontSize,
    this.padding,
    this.showIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipTheme = ChipTheme.of(context);
    
    Color? backgroundColor;
    Color? foregroundColor;
    Color? borderColor;
    double? elevation;
    OutlinedBorder? shape;
    
    switch (style) {
      case TagChipStyle.normal:
        backgroundColor = color?.withOpacity(0.1) ?? theme.colorScheme.primary.withOpacity(0.1);
        foregroundColor = color ?? theme.colorScheme.primary;
        borderColor = Colors.transparent;
        elevation = 0;
        shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
        break;
      case TagChipStyle.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = color ?? theme.colorScheme.primary;
        borderColor = color?.withOpacity(0.5) ?? theme.colorScheme.primary.withOpacity(0.5);
        elevation = 0;
        shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor!, width: 1),
        );
        break;
      case TagChipStyle.filled:
        backgroundColor = color ?? theme.colorScheme.primary;
        foregroundColor = theme.colorScheme.onPrimary;
        borderColor = Colors.transparent;
        elevation = 0;
        shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
        break;
      case TagChipStyle.selectable:
        backgroundColor = isSelected
            ? (color ?? theme.colorScheme.primary).withOpacity(0.2)
            : theme.colorScheme.surface;
        foregroundColor = isSelected
            ? (color ?? theme.colorScheme.primary)
            : theme.colorScheme.onSurface.withOpacity(0.6);
        borderColor = isSelected
            ? (color ?? theme.colorScheme.primary).withOpacity(0.3)
            : theme.colorScheme.outline.withOpacity(0.2);
        elevation = 0;
        shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor!, width: 1),
        );
        break;
      case TagChipStyle.editable:
        backgroundColor = color?.withOpacity(0.1) ?? theme.colorScheme.primary.withOpacity(0.1);
        foregroundColor = color ?? theme.colorScheme.primary;
        borderColor = Colors.transparent;
        elevation = 0;
        shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
        break;
    }
    
    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            _getTagIcon(tag),
            size: fontSize != null ? fontSize! * 0.9 : 14,
            color: foregroundColor,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          tag,
          style: TextStyle(
            fontSize: fontSize ?? 12,
            fontWeight: style == TagChipStyle.filled ? FontWeight.w500 : FontWeight.normal,
            color: foregroundColor,
          ),
        ),
        if (style == TagChipStyle.editable && onDelete != null) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: Icon(
              Icons.close,
              size: fontSize != null ? fontSize! * 0.8 : 12,
              color: foregroundColor,
            ),
          ),
        ],
      ],
    );
    
    if (onTap != null) {
      child = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: child,
      );
    }
    
    return Container(
      margin: const EdgeInsets.only(right: 4, bottom: 4),
      child: Material(
        elevation: elevation!,
        color: backgroundColor,
        shape: shape,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: child,
        ),
      ),
    );
  }
  
  IconData _getTagIcon(String tag) {
    // 根据标签文本返回对应图标（简单实现）
    final lowerTag = tag.toLowerCase();
    
    if (lowerTag.contains('工作') || lowerTag.contains('办公')) {
      return Icons.work_outline;
    } else if (lowerTag.contains('旅行') || lowerTag.contains('旅游')) {
      return Icons.flight_takeoff_outlined;
    } else if (lowerTag.contains('周末') || lowerTag.contains('假日')) {
      return Icons.weekend_outlined;
    } else if (lowerTag.contains('家庭') || lowerTag.contains('亲子')) {
      return Icons.family_restroom_outlined;
    } else if (lowerTag.contains('运动') || lowerTag.contains('健身')) {
      return Icons.sports_outlined;
    } else if (lowerTag.contains('探索') || lowerTag.contains('冒险')) {
      return Icons.explore_outlined;
    } else if (lowerTag.contains('摄影') || lowerTag.contains('拍照')) {
      return Icons.camera_alt_outlined;
    } else if (lowerTag.contains('放松') || lowerTag.contains('休闲')) {
      return Icons.spa_outlined;
    } else if (lowerTag.contains('美食') || lowerTag.contains('餐厅')) {
      return Icons.restaurant_outlined;
    } else if (lowerTag.contains('购物') || lowerTag.contains('买')) {
      return Icons.shopping_bag_outlined;
    } else if (lowerTag.contains('学习') || lowerTag.contains('教育')) {
      return Icons.school_outlined;
    } else {
      return Icons.tag_outlined;
    }
  }
}

/// 标签输入框（用于添加新标签）
class TagInputField extends StatefulWidget {
  final List<String> existingTags;
  final Function(String) onTagAdded;
  final String hintText;
  final int maxTags;
  final bool allowDuplicates;

  const TagInputField({
    Key? key,
    this.existingTags = const [],
    required this.onTagAdded,
    this.hintText = '添加标签...',
    this.maxTags = 10,
    this.allowDuplicates = false,
  }) : super(key: key);

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _controller.text.trim();
    if (tag.isEmpty) return;
    
    // 检查标签是否已存在
    if (!widget.allowDuplicates && widget.existingTags.contains(tag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('标签 "$tag" 已存在')),
      );
      return;
    }
    
    // 检查标签数量限制
    if (widget.existingTags.length >= widget.maxTags) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能添加 ${widget.maxTags} 个标签')),
      );
      return;
    }
    
    widget.onTagAdded(tag);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        suffixIcon: IconButton(
          onPressed: _addTag,
          icon: const Icon(Icons.add),
          tooltip: '添加标签',
        ),
      ),
      onSubmitted: (_) => _addTag(),
    );
  }
}

/// 标签列表（可编辑）
class EditableTagList extends StatefulWidget {
  final List<String> tags;
  final Function(List<String>) onTagsChanged;
  final int maxTags;
  final String hintText;

  const EditableTagList({
    Key? key,
    required this.tags,
    required this.onTagsChanged,
    this.maxTags = 10,
    this.hintText = '添加标签...',
  }) : super(key: key);

  @override
  State<EditableTagList> createState() => _EditableTagListState();
}

class _EditableTagListState extends State<EditableTagList> {
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.tags);
  }

  void _addTag(String tag) {
    if (_tags.length >= widget.maxTags) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('最多只能添加 ${widget.maxTags} 个标签')),
      );
      return;
    }
    
    setState(() {
      _tags.add(tag);
    });
    widget.onTagsChanged(_tags);
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 现有标签
        Wrap(
          children: _tags.map((tag) => TagChip(
            tag: tag,
            style: TagChipStyle.editable,
            onDelete: () => _removeTag(tag),
          )).toList(),
        ),
        
        const SizedBox(height: 8),
        
        // 标签输入框
        if (_tags.length < widget.maxTags)
          TagInputField(
            existingTags: _tags,
            onTagAdded: _addTag,
            hintText: widget.hintText,
            maxTags: widget.maxTags,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../constants/design_system.dart';

class FilterTags extends StatelessWidget {
  final String selectedTag;
  final ValueChanged<String> onSelect;

  const FilterTags({
    super.key,
    required this.selectedTag,
    required this.onSelect,
  });

  static const List<String> tags = ['全部', '简单', '中等', '困难'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tags.map((tag) {
          final isSelected = tag == selectedTag;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => onSelect(tag),
              selectedColor: DesignSystem.getPrimary(context),
              backgroundColor: DesignSystem.getBackgroundTertiary(context),
              labelStyle: TextStyle(
                color: isSelected 
                    ? DesignSystem.getTextInverse(context) 
                    : DesignSystem.getTextPrimary(context),
                fontSize: DesignSystem.fontBody,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignSystem.spacingLarge),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spacingSmall + 4,
                vertical: 4,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

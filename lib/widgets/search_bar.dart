import 'package:flutter/material.dart';
import '../constants/design_system.dart';

class SearchBar extends StatefulWidget {
  final ValueChanged<String>? onSearch;
  final String? hintText;

  const SearchBar({
    super.key,
    this.onSearch,
    this.hintText,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onClear() {
    _controller.clear();
    setState(() {});
  }

  void _onSubmitted(String value) {
    widget.onSearch?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.backgroundTertiaryDark : DesignSystem.background,
        borderRadius: BorderRadius.circular(DesignSystem.spacingLarge),
        boxShadow: DesignSystem.getShadow(context),
      ),
      child: TextField(
        controller: _controller,
        onChanged: (_) => setState(() {}),
        onSubmitted: _onSubmitted,
        style: TextStyle(
          color: DesignSystem.getTextPrimary(context),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText ?? '搜索',
          hintStyle: TextStyle(
            color: DesignSystem.getTextTertiary(context),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: DesignSystem.getTextSecondary(context),
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: DesignSystem.getTextSecondary(context),
                  ),
                  onPressed: _onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: DesignSystem.spacingMedium,
            horizontal: DesignSystem.spacingMedium,
          ),
        ),
      ),
    );
  }
}

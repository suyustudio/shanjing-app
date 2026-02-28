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
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.background,
        borderRadius: BorderRadius.circular(DesignSystem.spacingLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: (_) => setState(() {}),
        onSubmitted: _onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText ?? '搜索',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
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

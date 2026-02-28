import 'package:flutter/material.dart';

/// 通用加载状态组件
/// 
/// 显示加载指示器和可选的提示文本
class AppLoading extends StatelessWidget {
  /// 提示文本
  final String? message;
  
  /// 指示器颜色
  final Color? color;
  
  /// 指示器大小
  final double size;

  const AppLoading({
    super.key,
    this.message,
    this.color,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              color: color,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 小型加载指示器
class AppLoadingSmall extends StatelessWidget {
  final Color? color;
  final double size;

  const AppLoadingSmall({
    super.key,
    this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color ?? Colors.white,
      ),
    );
  }
}

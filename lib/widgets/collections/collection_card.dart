// collection_card.dart
// 山径APP - 收藏夹卡片组件

import 'package:flutter/material.dart';
import '../../models/collection_model.dart';
import '../../constants/design_system.dart';

/// 收藏夹卡片
class CollectionCard extends StatelessWidget {
  final Collection collection;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CollectionCard({
    Key? key,
    required this.collection,
    required this.onTap,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // P1: 统一使用设计系统定义的圆角和阴影
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: DesignSystem.getBackground(context),
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge), // 12px
        boxShadow: DesignSystem.getShadowLight(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 100,
            child: Row(
              children: [
                // 封面图
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    image: collection.coverUrl != null
                        ? DecorationImage(
                            image: NetworkImage(collection.coverUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: collection.coverUrl == null
                      ? Icon(
                          Icons.folder,
                          size: 40,
                          color: Colors.green.shade300,
                        )
                      : null,
                ),
                
                // 信息
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                collection.name,
                                style: DesignSystem.getTitleSmall(context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (collection.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5F3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '默认',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: DesignSystem.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${collection.trailCount} 条路线',
                          style: DesignSystem.getBodySmall(context),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              collection.isPublic ? Icons.public : Icons.lock,
                              size: 14,
                              color: DesignSystem.getTextTertiary(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              collection.isPublic ? '公开' : '私密',
                              style: TextStyle(
                                fontSize: 12,
                                color: DesignSystem.getTextTertiary(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 操作按钮
                if (!collection.isDefault && onDelete != null)
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('删除', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

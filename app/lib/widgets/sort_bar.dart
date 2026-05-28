import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/feed_post.dart';
import 'category_tabs.dart';

class SortBar extends StatelessWidget {
  final PostType? selected;
  final ValueChanged<PostType?> onSelect;

  const SortBar({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sort by', style: AppTypography.tabLabel),
                const SizedBox(width: 8),
                Icon(PhosphorIcons.arrowsDownUp(),
                    size: 16, color: AppColors.textTertiary),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: CategoryTabs(selected: selected, onSelect: onSelect),
          ),
        ],
      ),
    );
  }
}

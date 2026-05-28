import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/feed_post.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class _Tab {
  final PostType type;
  final String label;
  final IconData icon;
  const _Tab(this.type, this.label, this.icon);
}

class CategoryTabs extends StatelessWidget {
  final PostType? selected;
  final ValueChanged<PostType?> onSelect;

  const CategoryTabs({super.key, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final tabs = <_Tab>[
      _Tab(PostType.story, 'Stories', PhosphorIcons.bookOpen()),
      _Tab(PostType.recipe, 'Recipes', PhosphorIcons.chefHat()),
      _Tab(PostType.tradition, 'Traditions', PhosphorIcons.lampPendant()),
      _Tab(PostType.photoAlbum, 'Photo Albums', PhosphorIcons.images()),
      _Tab(PostType.document, 'Documents', PhosphorIcons.files()),
    ];

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: tabs.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final tab = tabs[i];
        final active = tab.type == selected;
        return _Chip(
          tab: tab,
          active: active,
          onTap: () => onSelect(active ? null : tab.type),
          onClear: active ? () => onSelect(null) : null,
        );
      },
    );
  }
}

class _Chip extends StatelessWidget {
  final _Tab tab;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _Chip({
    required this.tab,
    required this.active,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : AppColors.textTertiary;
    final bg = active ? AppColors.textTertiary : AppColors.chipBg;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9999),
      child: Container(
        height: 37,
        padding: EdgeInsets.fromLTRB(8, 8, active ? 8 : 16, 8),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9999)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 20, color: fg),
            const SizedBox(width: 8),
            Text(tab.label, style: AppTypography.tabLabel.copyWith(color: fg)),
            if (active) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Icon(Icons.close_rounded, size: 18, color: fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

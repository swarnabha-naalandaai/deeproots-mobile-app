import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/feed_post.dart';
import '../post_types/config/post_type_registry.dart';
import '../post_types/screens/create_post_screen.dart';
import '../post_types/utils/edit_values.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'post_menu.dart';

class CardHeader extends StatefulWidget {
  final FeedPost post;
  final VoidCallback? onMore;

  const CardHeader({super.key, required this.post, this.onMore});

  @override
  State<CardHeader> createState() => _CardHeaderState();
}

class _CardHeaderState extends State<CardHeader> {
  final GlobalKey _kebabKey = GlobalKey();

  void _handleMore() {
    if (widget.onMore != null) {
      widget.onMore!();
      return;
    }
    PostMenu.show(
      context,
      anchorKey: _kebabKey,
      isMine: widget.post.isMine,
      onEdit: _openEdit,
      onDelete: () => _snack('Deleted'),
      onAddToCollection: () => _snack('Added to collection'),
      onChangePrivacy: () => _snack('Privacy updated'),
      onShare: () => _snack('Shared'),
      onReport: () => _snack('Reported'),
    );
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  void _openEdit() {
    final config = PostTypeRegistry.findByDisplayName(
      registryDisplayNameFor(widget.post.type),
    );
    if (config == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreatePostScreen(
          config: config,
          initialValues: editValuesFor(widget.post),
          headerOverride: editHeaderFor(widget.post),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _Avatar(letter: widget.post.authorInitial),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.post.authorName, style: AppTypography.authorNameLg),
                const SizedBox(height: 2),
                Text(widget.post.timestamp, style: AppTypography.timestamp),
              ],
            ),
          ),
          _TypePill(widget.post.type.label),
          const SizedBox(width: 8),
          GestureDetector(
            key: _kebabKey,
            onTap: _handleMore,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 12,
              height: 24,
              child: OverflowBox(
                maxWidth: 24,
                maxHeight: 24,
                alignment: Alignment.centerLeft,
                child: Icon(
                  PhosphorIconsBold.dotsThreeVertical,
                  size: 24,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String letter;
  const _Avatar({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(letter, style: AppTypography.avatarLetter),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  const _TypePill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.typePillBg,
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(label, style: AppTypography.typePill),
    );
  }
}

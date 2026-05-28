import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/feed_post.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CardHeader extends StatelessWidget {
  final FeedPost post;
  final VoidCallback? onMore;

  const CardHeader({super.key, required this.post, this.onMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _Avatar(letter: post.authorInitial),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(post.authorName, style: AppTypography.authorNameLg),
                const SizedBox(height: 2),
                Text(post.timestamp, style: AppTypography.timestamp),
              ],
            ),
          ),
          _TypePill(post.type.label),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onMore,
            child: Icon(PhosphorIcons.dotsThreeVertical(),
                size: 24, color: AppColors.textTertiary),
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

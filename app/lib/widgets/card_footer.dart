import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CardFooter extends StatelessWidget {
  final int likes;
  final int comments;

  const CardFooter({super.key, required this.likes, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: AppColors.divider),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: SizedBox(
            height: 24,
            child: Row(
              children: [
                _CountIcon(icon: PhosphorIcons.heart(), value: likes),
                const SizedBox(width: 8),
                _CountIcon(icon: PhosphorIcons.chatDots(), value: comments),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CountIcon extends StatelessWidget {
  final IconData icon;
  final int value;
  const _CountIcon({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text('$value', style: AppTypography.countLabel),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class TagPill extends StatelessWidget {
  final String label;
  const TagPill(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.maroon,
        borderRadius: BorderRadius.circular(5434),
      ),
      alignment: Alignment.center,
      child: Text(label, style: AppTypography.tagPill),
    );
  }
}

class TagRow extends StatelessWidget {
  final List<String> tags;
  const TagRow(this.tags, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => TagPill(tags[i]),
      ),
    );
  }
}

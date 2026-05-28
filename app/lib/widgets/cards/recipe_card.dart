import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/feed_post.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../card_footer.dart';
import '../card_header.dart';
import '../expandable_text.dart';
import '../tag_pill.dart';
import '../tagged_people_sheet.dart';
import '../video_player_widget.dart';

class RecipeCard extends StatelessWidget {
  final RecipePost post;
  const RecipeCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(post: post),
          const SizedBox(height: 12),
          _Media(
            url: post.coverUrl,
            isVideo: post.isVideo,
            videoUrl: post.videoUrl,
            taggedPeople: post.taggedPeople,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(post.title, style: AppTypography.cardTitle),
                const SizedBox(height: 8),
                _MetaRow(
                  ingredients: post.ingredientsCount,
                  steps: post.stepsCount,
                  voice: post.hasVoiceNote,
                ),
                const SizedBox(height: 8),
                ExpandableText(text: post.description),
                const SizedBox(height: 12),
                TagRow(post.tags),
                const SizedBox(height: 12),
              ],
            ),
          ),
          CardFooter(likes: post.likes, comments: post.comments),
        ],
      ),
    );
  }
}

class _Media extends StatelessWidget {
  final String url;
  final bool isVideo;
  final String? videoUrl;
  final List<String> taggedPeople;
  const _Media({
    required this.url,
    required this.isVideo,
    this.videoUrl,
    this.taggedPeople = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 348,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isVideo && videoUrl != null)
            VideoPlayerWidget(videoUrl: videoUrl!, posterUrl: url)
          else
            CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
          Positioned(
            left: 10,
            bottom: 8,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: taggedPeople.isEmpty
                  ? null
                  : () => TaggedPeopleSheet.show(context, taggedPeople),
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(PhosphorIcons.userCircle(PhosphorIconsStyle.fill),
                    size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final int ingredients;
  final int steps;
  final bool voice;
  const _MetaRow({required this.ingredients, required this.steps, required this.voice});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      _MetaItem(icon: PhosphorIcons.cookingPot(), label: '$ingredients ingredients'),
      _MetaItem(icon: PhosphorIcons.list(), label: '$steps steps'),
      if (voice)
        _MetaItem(icon: PhosphorIcons.microphone(), label: 'voice note'),
    ];
    final separated = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      separated.add(items[i]);
      if (i < items.length - 1) {
        separated.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _Dot(),
        ));
      }
    }
    return Row(children: separated);
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.meta),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) => Container(
        width: 2,
        height: 2,
        decoration: const BoxDecoration(
          color: AppColors.textSecondary,
          shape: BoxShape.circle,
        ),
      );
}

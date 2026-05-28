import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/feed_post.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../card_footer.dart';
import '../card_header.dart';
import '../expandable_text.dart';
import '../waveform_player.dart';

class StoryCard extends StatelessWidget {
  final StoryPost post;
  const StoryCard({super.key, required this.post});

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
          SizedBox(
            height: 348,
            width: double.infinity,
            child: CachedNetworkImage(imageUrl: post.coverUrl, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: AppTypography.cardTitleLarge),
                const SizedBox(height: 16),
                WaveformPlayer(audioUrl: post.audioUrl, duration: post.duration),
                const SizedBox(height: 12),
                Text('TRANSCRIPTION:', style: AppTypography.metaLabel),
                const SizedBox(height: 8),
                ExpandableText(text: post.transcription),
                const SizedBox(height: 12),
                if (post.tags.isNotEmpty) ...[
                  // tags optional row reused via Wrap
                ],
                const SizedBox(height: 4),
              ],
            ),
          ),
          CardFooter(likes: post.likes, comments: post.comments),
        ],
      ),
    );
  }
}

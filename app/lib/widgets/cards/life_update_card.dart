import 'package:flutter/material.dart';
import '../../models/feed_post.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../card_footer.dart';
import '../card_header.dart';
import '../expandable_text.dart';
import '../tag_pill.dart';
import '../waveform_player.dart';

class LifeUpdateCard extends StatelessWidget {
  final LifeUpdatePost post;
  const LifeUpdateCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(post: post),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpandableText(text: post.body),
                if (post.audioUrl != null) ...[
                  const SizedBox(height: 12),
                  WaveformPlayer(
                    audioUrl: post.audioUrl!,
                    duration: post.audioDuration ?? const Duration(minutes: 1),
                  ),
                ],
                if (post.transcription != null &&
                    post.transcription!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('TRANSCRIPTION:', style: AppTypography.metaLabel),
                  const SizedBox(height: 8),
                  Text(post.transcription!, style: AppTypography.description),
                ],
                if (post.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TagRow(post.tags),
                ],
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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../models/feed_post.dart';
import '../../screens/album_gallery_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../card_footer.dart';
import '../card_header.dart';
import '../expandable_text.dart';
import '../tag_pill.dart';
import '../video_player_widget.dart';

class TraditionCard extends StatelessWidget {
  final TraditionPost post;
  const TraditionCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(post: post),
          const SizedBox(height: 16),
          SizedBox(
            height: 182,
            child: _ImageRow(
              images: post.images.take(3).toList(),
              firstIsVideo: post.firstIsVideo,
              videoUrl: post.videoUrl,
              title: post.title,
              allImages: post.images,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: AppTypography.cardTitleLarge),
                const SizedBox(height: 8),
                Text(post.frequencyLabel, style: AppTypography.annual),
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

class _ImageRow extends StatelessWidget {
  final List<String> images;
  final bool firstIsVideo;
  final String? videoUrl;
  final String title;
  final List<String> allImages;
  const _ImageRow({
    required this.images,
    required this.firstIsVideo,
    required this.title,
    required this.allImages,
    this.videoUrl,
  });

  void _openGallery(BuildContext context, int index) {
    final imageOnly = firstIsVideo ? allImages.skip(1).toList() : allImages;
    if (imageOnly.isEmpty) return;
    final adjusted = (firstIsVideo ? index - 1 : index).clamp(0, imageOnly.length - 1);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlbumGalleryScreen(
          title: title,
          images: imageOnly,
          initialIndex: adjusted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < images.length; i++)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: i < images.length - 1
                    ? const Border(right: BorderSide(color: AppColors.ink, width: 1))
                    : null,
              ),
              child: (i == 0 && firstIsVideo && videoUrl != null)
                  ? VideoPlayerWidget(
                      videoUrl: videoUrl!,
                      posterUrl: images[i],
                      overlaySize: 44,
                      iconSize: 18,
                    )
                  : GestureDetector(
                      onTap: () => _openGallery(context, i),
                      child: CachedNetworkImage(imageUrl: images[i], fit: BoxFit.cover),
                    ),
            ),
          ),
      ],
    );
  }
}

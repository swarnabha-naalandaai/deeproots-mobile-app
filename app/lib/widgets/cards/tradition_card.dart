import 'package:flutter/material.dart';
import '../../models/feed_post.dart';
import '../../screens/album_gallery_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../card_footer.dart';
import '../card_header.dart';
import '../expandable_text.dart';
import '../tag_pill.dart';
import 'media_carousel.dart';

class TraditionCard extends StatelessWidget {
  final TraditionPost post;
  const TraditionCard({super.key, required this.post});

  void _openGallery(BuildContext context, int carouselIndex) {
    final imageOnly =
        post.firstIsVideo ? post.images.skip(1).toList() : post.images;
    if (imageOnly.isEmpty) return;
    final adjusted = (post.firstIsVideo ? carouselIndex - 1 : carouselIndex)
        .clamp(0, imageOnly.length - 1);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlbumGalleryScreen(
          title: post.title,
          images: imageOnly,
          initialIndex: adjusted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(post: post),
          const SizedBox(height: 16),
          MediaCarousel(
            images: post.images,
            firstIsVideo: post.firstIsVideo,
            videoUrl: post.videoUrl,
            onImageTap: (i) => _openGallery(context, i),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: AppTypography.cardTitle),
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

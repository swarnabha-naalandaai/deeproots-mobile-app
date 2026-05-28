import 'package:flutter/material.dart';
import '../../models/feed_post.dart';
import '../../screens/album_gallery_screen.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../card_footer.dart';
import '../card_header.dart';
import '../expandable_text.dart';
import 'media_carousel.dart';

class PhotoAlbumCard extends StatelessWidget {
  final PhotoAlbumPost post;
  const PhotoAlbumCard({super.key, required this.post});

  void _openGallery(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlbumGalleryScreen(
          title: post.title,
          images: post.images,
          initialIndex: index.clamp(0, post.images.length - 1),
        ),
      ),
    );
  }

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
          MediaCarousel(
            images: post.images,
            onImageTap: (i) => _openGallery(context, i),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: AppTypography.cardTitle),
                const SizedBox(height: 8),
                ExpandableText(text: post.description),
              ],
            ),
          ),
          CardFooter(likes: post.likes, comments: post.comments),
        ],
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../models/feed_post.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../screens/album_gallery_screen.dart';
import '../card_footer.dart';
import '../card_header.dart';

class PhotoAlbumCard extends StatelessWidget {
  final PhotoAlbumPost post;
  const PhotoAlbumCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final first = post.images.isNotEmpty ? post.images[0] : '';
    final second = post.images.length > 1 ? post.images[1] : first;
    return Container(
      color: AppColors.cardBackground,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardHeader(post: post),
          const SizedBox(height: 12),
          SizedBox(
            height: 182,
            child: Row(
              children: [
                Expanded(
                  flex: 199,
                  child: GestureDetector(
                    onTap: () => _openGallery(context, 0),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          right: BorderSide(color: AppColors.separator, width: 1),
                        ),
                      ),
                      child: CachedNetworkImage(imageUrl: first, fit: BoxFit.cover),
                    ),
                  ),
                ),
                Expanded(
                  flex: 213,
                  child: GestureDetector(
                    onTap: () => _openGallery(context, 1),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(imageUrl: second, fit: BoxFit.cover),
                        Container(color: Colors.black.withValues(alpha: 0.69)),
                        Center(
                          child: Text(
                            '+${post.extraCount}',
                            style: AppTypography.plusCount,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: AppTypography.cardTitleLarge),
                const SizedBox(height: 8),
                _MetaRow(
                  ingredients: post.ingredientsCount,
                  steps: post.stepsCount,
                  voice: post.hasVoiceNote,
                ),
                const SizedBox(height: 8),
                Text(
                  post.description,
                  style: AppTypography.description,
                ),
              ],
            ),
          ),
          CardFooter(likes: post.likes, comments: post.comments),
        ],
      ),
    );
  }

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
}

class _MetaRow extends StatelessWidget {
  final int ingredients;
  final int steps;
  final bool voice;
  const _MetaRow({required this.ingredients, required this.steps, required this.voice});

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      _Item(icon: PhosphorIcons.cookingPot(), label: '$ingredients ingredients'),
      _Item(icon: PhosphorIcons.list(), label: '$steps steps'),
      if (voice) _Item(icon: PhosphorIcons.microphone(), label: 'voice note'),
    ];
    final out = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      out.add(items[i]);
      if (i < items.length - 1) {
        out.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: _Dot(),
        ));
      }
    }
    return Row(children: out);
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Item({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.meta),
        ],
      );
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

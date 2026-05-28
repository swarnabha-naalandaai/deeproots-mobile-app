import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../theme/app_typography.dart';
import '../video_player_widget.dart';

class MediaCarousel extends StatefulWidget {
  final List<String> images;
  final bool firstIsVideo;
  final String? videoUrl;
  final void Function(int index)? onImageTap;

  const MediaCarousel({
    super.key,
    required this.images,
    this.firstIsVideo = false,
    this.videoUrl,
    this.onImageTap,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  final PageController _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.images.length;
    return SizedBox(
      height: 348,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: total,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, index) {
              final isVideo =
                  index == 0 && widget.firstIsVideo && widget.videoUrl != null;
              if (isVideo) {
                return VideoPlayerWidget(
                  videoUrl: widget.videoUrl!,
                  posterUrl: widget.images[index],
                  overlaySize: 44,
                  iconSize: 18,
                );
              }
              final tap = widget.onImageTap;
              return GestureDetector(
                onTap: tap == null ? null : () => tap(index),
                child: CachedNetworkImage(
                  imageUrl: widget.images[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          if (total > 1) ...[
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3E3E3E),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '${_current + 1}/$total',
                  style: AppTypography.counterPill,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(child: _Pager(total: total, current: _current)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  final int total;
  final int current;
  const _Pager({required this.total, required this.current});

  static const int _maxDots = 8;
  static const Color _active = Color(0xFF2D95E4);
  static const Color _inactive = Colors.white;

  @override
  Widget build(BuildContext context) {
    final dotCount = total <= _maxDots ? total : _maxDots;
    int windowStart = 0;
    if (total > _maxDots) {
      windowStart = (current - _maxDots ~/ 2).clamp(0, total - _maxDots);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(dotCount, (i) {
        final globalIdx = windowStart + i;
        final isActive = globalIdx == current;
        double size = 4;
        if (total > _maxDots) {
          final hasLeftOverflow = windowStart > 0;
          final hasRightOverflow = windowStart + dotCount < total;
          if (i == 0 && hasLeftOverflow) size = 2;
          if (i == dotCount - 1 && hasRightOverflow) size = 2;
        }
        if (isActive) size = 5;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isActive ? _active : _inactive,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

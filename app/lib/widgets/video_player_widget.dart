import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_colors.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String posterUrl;
  final double overlaySize;
  final double iconSize;
  final BoxFit fit;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.posterUrl,
    this.overlaySize = 80,
    this.iconSize = 28,
    this.fit = BoxFit.cover,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final VideoPlayerController _controller;
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    _controller.addListener(_onValueChanged);
    _controller.setLooping(true);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _initialized = true);
    }).catchError((Object e) {
      if (!mounted) return;
      setState(() => _error = true);
    });
  }

  void _onValueChanged() {
    if (!mounted) return;
    if (_controller.value.hasError && !_error) {
      setState(() => _error = true);
      return;
    }
    setState(() {});
  }

  void _toggle() {
    if (!_initialized) return;
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onValueChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = _controller.value;
    final isPlaying = _initialized && v.isPlaying;
    final showSpinner = !_initialized && !_error;

    return GestureDetector(
      onTap: _toggle,
      child: ClipRect(
        child: Stack(
        fit: StackFit.expand,
        children: [
          if (_initialized)
            FittedBox(
              fit: widget.fit,
              child: SizedBox(
                width: v.size.width == 0 ? 16 : v.size.width,
                height: v.size.height == 0 ? 9 : v.size.height,
                child: VideoPlayer(_controller),
              ),
            )
          else
            CachedNetworkImage(imageUrl: widget.posterUrl, fit: widget.fit),
          if (!isPlaying)
            Center(
              child: Container(
                width: widget.overlaySize,
                height: widget.overlaySize,
                decoration: BoxDecoration(
                  color: AppColors.overlay,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: showSpinner
                    ? SizedBox(
                        width: widget.iconSize,
                        height: widget.iconSize,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _error
                            ? PhosphorIcons.warning(PhosphorIconsStyle.fill)
                            : PhosphorIcons.play(PhosphorIconsStyle.fill),
                        size: widget.iconSize,
                        color: AppColors.ink,
                      ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

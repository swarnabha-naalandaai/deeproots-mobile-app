import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../../theme/app_colors.dart';
import '../../../screens/recipe_record_screen.dart';
import '../../../screens/video_record_screen.dart';
import '../../../widgets/form/form_tokens.dart';
import '../../config/field_config.dart';

class RecipeRecordWidget extends StatefulWidget {
  final RecipeRecordConfig config;
  final RecipeRecordResult? value;
  final ValueChanged<RecipeRecordResult?> onChanged;
  final void Function(Map<String, dynamic> fields)? onBulkChanged;

  const RecipeRecordWidget({
    super.key,
    required this.config,
    required this.value,
    required this.onChanged,
    this.onBulkChanged,
  });

  @override
  State<RecipeRecordWidget> createState() => _RecipeRecordWidgetState();
}

class _RecipeRecordWidgetState extends State<RecipeRecordWidget> {
  VideoPlayerController? _videoPlayer;

  @override
  void didUpdateWidget(RecipeRecordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _disposeVideo();
      if (widget.value != null && widget.value!.isVideo && widget.value!.path.isNotEmpty) {
        _initVideo();
      }
    }
  }

  void _initVideo() {
    _videoPlayer = VideoPlayerController.file(File(widget.value!.path))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  void _disposeVideo() {
    _videoPlayer?.dispose();
    _videoPlayer = null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.value != null && widget.value!.isVideo && widget.value!.path.isNotEmpty) {
      _initVideo();
    }
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  Future<void> _openVoiceRecord(BuildContext context) async {
    final result = await RecipeRecordScreen.open(context);
    if (result == null) return;
    widget.onChanged(result);
    if (result.extractedFields.isNotEmpty && widget.onBulkChanged != null) {
      widget.onBulkChanged!(result.extractedFields);
    }
  }

  Future<void> _openVideoRecord(BuildContext context) async {
    final result = await VideoRecordScreen.open(context);
    if (result == null) return;
    widget.onChanged(result);
    if (result.extractedFields.isNotEmpty && widget.onBulkChanged != null) {
      widget.onBulkChanged!(result.extractedFields);
    }
  }

  void _togglePlayback() {
    if (_videoPlayer == null) return;
    setState(() {
      if (_videoPlayer!.value.isPlaying) {
        _videoPlayer!.pause();
      } else {
        _videoPlayer!.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value != null) return _extractedSection(context);
    return _recordButtons(context);
  }

  Widget _recordButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _pillBtn(
                icon: PhosphorIcons.sparkle(),
                label: widget.config.voiceLabel,
                onTap: () => _openVoiceRecord(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _pillBtn(
                icon: PhosphorIcons.videoCamera(),
                label: widget.config.videoLabel,
                onTap: () => _openVideoRecord(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.config.subtitle,
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            height: 20 / 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _pillBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: FormTokens.recordBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.ink),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 21 / 14,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _extractedSection(BuildContext context) {
    final dur = widget.value!.duration;
    final m = dur.inMinutes;
    final s = dur.inSeconds.remainder(60).toString().padLeft(2, '0');
    final timeStr = '$m:$s';
    final mediaType = widget.value!.isVideo ? 'video' : 'voice';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.value!.isVideo) ...[
          _videoPreview(),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 20, 16),
          decoration: BoxDecoration(
            color: FormTokens.recordBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(PhosphorIcons.sparkle(), size: 20, color: AppColors.ink),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Extracted from your $timeStr $mediaType recording. Edit anything before posting.',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 21 / 16,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _videoPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 200,
        width: double.infinity,
        color: Colors.black,
        child: _videoPlayer != null && _videoPlayer!.value.isInitialized
            ? GestureDetector(
                onTap: _togglePlayback,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: _videoPlayer!.value.size.width,
                        height: _videoPlayer!.value.size.height,
                        child: VideoPlayer(_videoPlayer!),
                      ),
                    ),
                    if (!_videoPlayer!.value.isPlaying)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(128),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          PhosphorIcons.play(PhosphorIconsStyle.fill),
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              )
            : const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}

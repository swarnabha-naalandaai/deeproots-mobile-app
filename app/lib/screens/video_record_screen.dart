import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../post_types/config/field_config.dart';
import '../widgets/recording_controls.dart';

enum _Phase { idle, recording, review, transcribing, extracting }

class VideoRecordScreen extends StatefulWidget {
  const VideoRecordScreen({super.key});

  static Future<RecipeRecordResult?> open(BuildContext context) {
    return Navigator.of(context).push<RecipeRecordResult>(
      MaterialPageRoute(builder: (_) => const VideoRecordScreen()),
    );
  }

  @override
  State<VideoRecordScreen> createState() => _VideoRecordScreenState();
}

class _VideoRecordScreenState extends State<VideoRecordScreen> {
  static const Color _darkBg = Color(0xFF202020);
  static const Color _bottomBar = Color(0xFF2B2B2B);

  CameraController? _camera;
  VideoPlayerController? _videoPlayer;
  _Phase _phase = _Phase.idle;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _filePath;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final back = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      _camera = CameraController(back, ResolutionPreset.high, enableAudio: true);
      await _camera!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _camera?.dispose();
    _videoPlayer?.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_camera == null || !_camera!.value.isInitialized) return;
    try {
      await _camera!.startVideoRecording();
      _elapsed = Duration.zero;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });
      if (mounted) setState(() => _phase = _Phase.recording);
    } catch (_) {}
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    try {
      final file = await _camera!.stopVideoRecording();
      _filePath = file.path;
    } catch (_) {}

    _videoPlayer?.dispose();
    if (_filePath != null) {
      _videoPlayer = VideoPlayerController.file(File(_filePath!));
      await _videoPlayer!.initialize();
    }
    if (mounted) setState(() => _phase = _Phase.review);
  }

  Future<void> _reRecord() async {
    _videoPlayer?.dispose();
    _videoPlayer = null;
    _elapsed = Duration.zero;
    _filePath = null;
    setState(() => _phase = _Phase.idle);
  }

  Future<void> _useRecording() async {
    _videoPlayer?.pause();
    setState(() => _phase = _Phase.transcribing);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() => _phase = _Phase.extracting);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final result = RecipeRecordResult(
      path: _filePath ?? '',
      duration: _elapsed,
      extractedFields: dummyRecipeExtraction(),
      isVideo: true,
    );
    Navigator.of(context).pop(result);
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
    if (_phase == _Phase.transcribing || _phase == _Phase.extracting) {
      return _processingScaffold();
    }
    if (_phase == _Phase.review) {
      return _reviewScaffold();
    }
    return _recordingScaffold();
  }

  Widget _recordingScaffold() {
    return Scaffold(
      backgroundColor: _darkBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            if (_phase == _Phase.recording) _recOverlay(),
            Expanded(child: _cameraPreview()),
            _bottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _recOverlay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: RecordingColors.recRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'REC',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.1,
                  color: const Color(0xFFF7F7F7),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: RecordingColors.timerPillBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              formatRecordingTime(_elapsed),
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 16 / 12,
                letterSpacing: 0.06 * 12,
                color: RecordingColors.stopBg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraPreview() {
    if (!_cameraReady || _camera == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _camera!.value.previewSize?.height ?? 1,
            height: _camera!.value.previewSize?.width ?? 1,
            child: CameraPreview(_camera!),
          ),
        ),
      ),
    );
  }

  Widget _bottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: const BoxDecoration(color: _bottomBar),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_phase == _Phase.idle)
            RecordingStartButton(onTap: _startRecording),
          if (_phase == _Phase.recording)
            RecordingStopButton(onTap: _stopRecording, textColor: const Color(0xFFF7F7F7)),
        ],
      ),
    );
  }

  Widget _reviewScaffold() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            RecordingHeader(onBack: () => Navigator.of(context).pop()),
            _videoPreviewArea(),
            const Spacer(),
            Text(
              formatRecordingTime(_elapsed),
              style: GoogleFonts.dmSans(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                height: 24 / 23,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _togglePlayback,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  (_videoPlayer?.value.isPlaying ?? false)
                      ? PhosphorIcons.pause(PhosphorIconsStyle.fill)
                      : PhosphorIcons.play(PhosphorIconsStyle.fill),
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            RecordingReviewButtons(onReRecord: _reRecord, onUse: _useRecording),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _videoPreviewArea() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.black,
      child: _videoPlayer != null && _videoPlayer!.value.isInitialized
          ? GestureDetector(
              onTap: _togglePlayback,
              child: FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: _videoPlayer!.value.size.width,
                  height: _videoPlayer!.value.size.height,
                  child: VideoPlayer(_videoPlayer!),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  Widget _processingScaffold() {
    final title = _phase == _Phase.transcribing
        ? 'Analyzing your video...'
        : 'Extracting ingredients...';
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            RecordingHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(child: RecordingProcessingView(title: title)),
          ],
        ),
      ),
    );
  }
}

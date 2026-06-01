import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_colors.dart';
import '../post_types/config/field_config.dart';
import '../widgets/recording_controls.dart';

enum _Phase { idle, recording, review, transcribing, extracting }

class RecipeRecordScreen extends StatefulWidget {
  const RecipeRecordScreen({super.key});

  static Future<RecipeRecordResult?> open(BuildContext context) {
    return Navigator.of(context).push<RecipeRecordResult>(
      MaterialPageRoute(builder: (_) => const RecipeRecordScreen()),
    );
  }

  @override
  State<RecipeRecordScreen> createState() => _RecipeRecordScreenState();
}

class _RecipeRecordScreenState extends State<RecipeRecordScreen> {
  static const Color _ringBg = Color(0x80DAC9A3);
  static const Color _micBg = Color(0xFFA07A23);

  final AudioRecorder _recorder = AudioRecorder();
  final stt.SpeechToText _speech = stt.SpeechToText();
  _Phase _phase = _Phase.idle;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _filePath;
  String _transcript = '';

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (!await _recorder.hasPermission()) return;
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/recipe_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      _filePath = path;

      final ok = await _speech.initialize(onError: (_) {}, onStatus: (_) {});
      if (ok) {
        await _speech.listen(
          onResult: (r) {
            if (mounted) setState(() => _transcript = r.recognizedWords);
          },
          listenOptions: stt.SpeechListenOptions(
            partialResults: true,
            cancelOnError: false,
            listenMode: stt.ListenMode.dictation,
            listenFor: const Duration(minutes: 10),
            pauseFor: const Duration(seconds: 30),
          ),
        );
      }

      _elapsed = Duration.zero;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
      });
      if (mounted) setState(() => _phase = _Phase.recording);
    } catch (_) {}
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    await _speech.stop();
    try {
      if (await _recorder.isRecording()) {
        _filePath = await _recorder.stop() ?? _filePath;
      }
    } catch (_) {}
    if (mounted) setState(() => _phase = _Phase.review);
  }

  Future<void> _reRecord() async {
    _transcript = '';
    _elapsed = Duration.zero;
    _filePath = null;
    setState(() => _phase = _Phase.idle);
  }

  Future<void> _useRecording() async {
    setState(() => _phase = _Phase.transcribing);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() => _phase = _Phase.extracting);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final result = RecipeRecordResult(
      path: _filePath ?? '',
      duration: _elapsed,
      transcript: _transcript.isEmpty ? null : _transcript,
      extractedFields: dummyRecipeExtraction(),
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            RecordingHeader(onBack: () => Navigator.of(context).pop()),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    if (_phase == _Phase.transcribing || _phase == _Phase.extracting) {
      final title = _phase == _Phase.transcribing
          ? 'Listening to your recipe...'
          : 'Extracting ingredients...';
      return RecordingProcessingView(title: title);
    }
    return Column(
      children: [
        const Spacer(flex: 3),
        _micOrb(),
        const SizedBox(height: 16),
        Text(
          formatRecordingTime(_elapsed),
          style: GoogleFonts.dmSans(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            height: 24 / 23,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        const RecordingWaveform(),
        if (_phase == _Phase.review) ...[
          const SizedBox(height: 16),
          _playButton(),
        ],
        const Spacer(flex: 2),
        if (_phase == _Phase.idle)
          RecordingStartButton(onTap: _startRecording),
        if (_phase == _Phase.recording)
          RecordingStopButton(onTap: _stopRecording),
        if (_phase == _Phase.review)
          RecordingReviewButtons(onReRecord: _reRecord, onUse: _useRecording),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _micOrb() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: _ringBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Container(
        width: 90,
        height: 90,
        decoration: const BoxDecoration(
          color: _micBg,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          PhosphorIcons.microphone(),
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _playButton() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: _micBg,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        PhosphorIcons.play(PhosphorIconsStyle.fill),
        size: 20,
        color: Colors.white,
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_colors.dart';
import '../post_types/config/field_config.dart';

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
  static const Color _stopBg = Color(0xFF7E2525);
  static const Color _barColor = Color(0xFFDAC9A3);
  static const _barHeights = [17, 23, 31, 23, 17, 23, 17, 31, 23, 31, 17, 31, 23, 17];

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

  String get _formatted {
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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
      extractedFields: {
        'title': 'Aloo Paratha — my mother\'s way, with extra ghee',
        'caption':
            'Sunday breakfast at home, the kind that makes you sit and not move for two hours after.',
        'ingredients': <String>[
          'Wheat flour — 2 cups',
          'Potatoes — 4 medium, boiled',
          'Green chili — 1 finely chopped',
          'Jeera — 1 tsp, grated',
          'Coriander — small handful, chopped',
          'Cumin seeds — 1 tsp, roasted and crushed',
          'Red chilli powder — 1 tsp',
          'Amchur (dry mango powder) — 1 tsp',
        ],
        'steps': <String>[
          'Knead a soft dough with the flour, a pinch of salt, and water. Rest for 30 minutes.',
          'Mash the boiled potatoes till there are no lumps.',
          'Mix in green chili, ginger, coriander, all the spices and salt. Taste the filling — it should be slightly over-seasoned.',
          'Divide both dough and filling into equal portions, about ping-pong-ball sized.',
        ],
      },
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
            _header(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFB0A24A), width: 0.5)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Icon(PhosphorIcons.caretLeft(), size: 24, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Record the recipe',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _body() {
    if (_phase == _Phase.transcribing || _phase == _Phase.extracting) {
      return _processingView();
    }
    return Column(
      children: [
        const Spacer(flex: 3),
        _micOrb(),
        const SizedBox(height: 16),
        Text(
          _formatted,
          style: GoogleFonts.dmSans(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            height: 24 / 23,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8),
        _waveform(),
        if (_phase == _Phase.review) ...[
          const SizedBox(height: 16),
          _playButton(),
        ],
        const Spacer(flex: 2),
        if (_phase == _Phase.idle) _tapToRecord(),
        if (_phase == _Phase.recording) _stopButton(),
        if (_phase == _Phase.review) _reviewButtons(),
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

  Widget _waveform() {
    return SizedBox(
      height: 31,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < _barHeights.length; i++) ...[
            Container(
              width: 6,
              height: _barHeights[i].toDouble(),
              decoration: BoxDecoration(
                color: _barColor,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            if (i != _barHeights.length - 1) const SizedBox(width: 4),
          ],
        ],
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

  Widget _tapToRecord() {
    return Column(
      children: [
        GestureDetector(
          onTap: _startRecording,
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: _stopBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: 33,
              height: 33,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tap to start recording',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.1,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _stopButton() {
    return GestureDetector(
      onTap: _stopRecording,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: _stopBg,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _reviewButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _reRecord,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'Re-record',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.1,
              color: AppColors.textTertiary,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        const SizedBox(width: 24),
        GestureDetector(
          onTap: _useRecording,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Use this recording',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _processingView() {
    final title = _phase == _Phase.transcribing
        ? 'Listening to your recipe...'
        : 'Extracting ingredients...';
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _waveform(),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Just a moment',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.3,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

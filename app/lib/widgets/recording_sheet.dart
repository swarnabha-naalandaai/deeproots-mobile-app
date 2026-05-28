import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_colors.dart';

class RecordingResult {
  final String? path;
  final Duration duration;
  final String? transcript;
  const RecordingResult({this.path, required this.duration, this.transcript});
}

class RecordingSheet extends StatefulWidget {
  final String title;
  final bool transcribe;
  const RecordingSheet({
    super.key,
    required this.title,
    this.transcribe = false,
  });

  static Future<RecordingResult?> show(
    BuildContext context, {
    required String title,
    bool transcribe = false,
  }) {
    return showModalBottomSheet<RecordingResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x26000000),
      isDismissible: false,
      enableDrag: false,
      builder: (_) => RecordingSheet(title: title, transcribe: transcribe),
    );
  }

  @override
  State<RecordingSheet> createState() => _RecordingSheetState();
}

class _RecordingSheetState extends State<RecordingSheet> {
  static const Color _ringBg = Color(0x7DDAC9A3);
  static const Color _stopBg = Color(0xFFA07A23);
  static const Color _muteBg = Color(0xFFF5F4EE);
  static const Color _barColor = Color(0xFFDAC9A3);
  static const _barHeights = [17, 23, 31, 23, 17, 23, 17, 31, 23, 31, 17, 31, 23, 17];

  final AudioRecorder _recorder = AudioRecorder();
  final stt.SpeechToText _speech = stt.SpeechToText();
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  String? _filePath;
  String _transcript = '';
  String _transcriptPrefix = '';
  bool _starting = true;
  bool _paused = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      if (widget.transcribe) {
        await _startTranscription();
      } else {
        await _startAudio();
      }
      if (!mounted) return;
      setState(() => _starting = false);
      _startTimer();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to start');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _startAudio() async {
    if (!await _recorder.hasPermission()) {
      throw 'mic-denied';
    }
    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );
    _filePath = path;
  }

  Future<void> _startTranscription() async {
    if (_filePath == null) {
      try {
        await _startAudio();
      } catch (_) {
        _filePath = null;
      }
    } else {
      try {
        await _recorder.resume();
      } catch (_) {}
    }
    final ok = await _speech.initialize(
      onError: (err) {
        if (!mounted) return;
        setState(() => _error = err.errorMsg);
      },
      onStatus: (_) {},
    );
    if (!ok) throw 'speech-init-failed';
    await _speech.listen(
      onResult: (r) {
        if (!mounted) return;
        final tail = r.recognizedWords;
        final merged = _transcriptPrefix.isEmpty
            ? tail
            : (tail.isEmpty ? _transcriptPrefix : '$_transcriptPrefix $tail');
        setState(() => _transcript = merged);
      },
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: stt.ListenMode.dictation,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 30),
      ),
    );
  }

  Future<void> _togglePause() async {
    if (_starting || _error != null) return;
    if (_paused) {
      if (widget.transcribe) {
        _transcriptPrefix = _transcript;
        await _startTranscription();
      } else {
        await _recorder.resume();
      }
      _startTimer();
      if (!mounted) return;
      setState(() => _paused = false);
    } else {
      _timer?.cancel();
      if (widget.transcribe) {
        await _speech.stop();
        try {
          if (await _recorder.isRecording()) {
            await _recorder.pause();
          }
        } catch (_) {}
      } else {
        await _recorder.pause();
      }
      if (!mounted) return;
      setState(() => _paused = true);
    }
  }

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

  Future<void> _stop() async {
    _timer?.cancel();
    if (widget.transcribe) {
      await _speech.stop();
      String? path;
      try {
        if (await _recorder.isRecording() || await _recorder.isPaused()) {
          path = await _recorder.stop();
        }
      } catch (_) {}
      if (!mounted) return;
      Navigator.of(context).pop(
        RecordingResult(
          path: path,
          duration: _elapsed,
          transcript: _transcript.trim().isEmpty ? null : _transcript.trim(),
        ),
      );
    } else {
      final path = await _recorder.stop();
      if (!mounted) return;
      if (path == null) {
        Navigator.of(context).pop();
        return;
      }
      Navigator.of(context).pop(
        RecordingResult(path: path, duration: _elapsed),
      );
    }
  }

  Future<void> _cancel() async {
    _timer?.cancel();
    if (widget.transcribe) {
      await _speech.cancel();
    }
    try {
      if (await _recorder.isRecording() || await _recorder.isPaused()) {
        await _recorder.stop();
      }
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.all(10),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFFD3D2CE),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    _error ?? widget.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      color: _error != null
                          ? AppColors.maroon
                          : AppColors.textTertiary,
                    ),
                  ),
                  if (widget.transcribe && _transcript.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 80),
                      child: SingleChildScrollView(
                        reverse: true,
                        child: Text(
                          _transcript,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            height: 1.3,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: _ringBg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: _starting || _error != null ? null : _stop,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: _stopBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: _starting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
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
                      SizedBox(
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
                              if (i != _barHeights.length - 1)
                                const SizedBox(width: 4),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _togglePause,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 48.5,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: _muteBg,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _paused
                            ? PhosphorIcons.play(PhosphorIconsStyle.fill)
                            : PhosphorIcons.pause(PhosphorIconsStyle.fill),
                        size: 18,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _cancel,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: AppColors.textTertiary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  String? get filePath => _filePath;
}

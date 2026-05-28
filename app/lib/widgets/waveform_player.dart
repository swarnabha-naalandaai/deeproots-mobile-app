import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class WaveformPlayer extends StatefulWidget {
  final String audioUrl;
  final Duration duration;

  const WaveformPlayer({
    super.key,
    required this.audioUrl,
    required this.duration,
  });

  @override
  State<WaveformPlayer> createState() => _WaveformPlayerState();
}

class _WaveformPlayerState extends State<WaveformPlayer> {
  static const int _barCount = 36;
  final AudioPlayer _player = AudioPlayer();
  final List<double> _bars = _generateBars(_barCount);
  bool _ready = false;
  bool _failed = false;

  static List<double> _generateBars(int n) {
    final rng = math.Random(7);
    return List<double>.generate(n, (i) {
      final base = 0.3 + rng.nextDouble() * 0.7;
      final wave = 0.5 + 0.5 * math.sin(i / n * math.pi * 4);
      return (base * wave).clamp(0.18, 1.0);
    });
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await _player.setUrl(widget.audioUrl);
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _toggle() {
    if (!_ready) return;
    if (_player.playing) {
      _player.pause();
    } else {
      if ((_player.position) >= (_player.duration ?? widget.duration)) {
        _player.seek(Duration.zero);
      }
      _player.play();
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      decoration: BoxDecoration(
        color: AppColors.typePillBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.typePillText,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: StreamBuilder<bool>(
                stream: _player.playingStream,
                builder: (_, snap) {
                  final playing = snap.data ?? false;
                  return Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (_, snap) {
                final pos = snap.data ?? Duration.zero;
                final total = _player.duration ?? widget.duration;
                final progress = total.inMilliseconds == 0
                    ? 0.0
                    : (pos.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
                return CustomPaint(
                  size: const Size.fromHeight(30),
                  painter: _WaveformPainter(bars: _bars, progress: progress),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (_, snap) {
              final pos = snap.data ?? Duration.zero;
              final total = _player.duration ?? widget.duration;
              final remaining = total - pos;
              final label = _failed
                  ? _fmt(widget.duration)
                  : _fmt(remaining < Duration.zero ? Duration.zero : remaining);
              return Text(label, style: AppTypography.duration);
            },
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> bars;
  final double progress;
  _WaveformPainter({required this.bars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final activeColor = AppColors.typePillText;
    const inactiveColor = AppColors.textSecondary;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    final gap = size.width / bars.length;
    for (int i = 0; i < bars.length; i++) {
      final h = bars[i] * size.height;
      final x = gap * i + gap / 2;
      paint.color =
          (i / bars.length) <= progress ? activeColor : inactiveColor;
      canvas.drawLine(
        Offset(x, (size.height - h) / 2),
        Offset(x, (size.height + h) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter old) =>
      old.progress != progress || old.bars != bars;
}

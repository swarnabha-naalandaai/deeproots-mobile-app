import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class VoicePreviewBar extends StatefulWidget {
  final String filePath;
  final Duration totalHint;
  final VoidCallback? onClose;

  const VoicePreviewBar({
    super.key,
    required this.filePath,
    required this.totalHint,
    this.onClose,
  });

  @override
  State<VoicePreviewBar> createState() => _VoicePreviewBarState();
}

class _VoicePreviewBarState extends State<VoicePreviewBar> {
  static const Color _bg = Color(0xFFF5F4EE);
  static const Color _played = Color(0xFFA07A23);
  static const Color _unplayed = Color(0xFF999999);
  static const Color _meta = Color(0xFF5F5F5F);
  static const List<int> _heights = [
    15, 15, 13, 9, 9, 12, 15, 9, 12, 15, 15, 15, 13, 9, 9,
    12, 15, 9, 12, 15, 15, 13, 11, 15, 15, 15, 13, 11, 15, 15,
    15, 13, 9, 9, 12, 15, 13, 9,
  ];

  final AudioPlayer _player = AudioPlayer();
  Duration _position = Duration.zero;
  Duration _total = Duration.zero;
  bool _playing = false;
  StreamSubscription? _posSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _durSub;

  @override
  void initState() {
    super.initState();
    _total = widget.totalHint;
    _load();
  }

  Future<void> _load() async {
    try {
      await _player.setFilePath(widget.filePath);
    } catch (_) {}
    _durSub = _player.durationStream.listen((d) {
      if (!mounted || d == null) return;
      setState(() => _total = d);
    });
    _posSub = _player.positionStream.listen((p) {
      if (!mounted) return;
      setState(() => _position = p);
    });
    _stateSub = _player.playerStateStream.listen((s) {
      if (!mounted) return;
      setState(() => _playing = s.playing);
      if (s.processingState == ProcessingState.completed) {
        _player.pause();
        _player.seek(Duration.zero);
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _durSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      await _player.play();
    }
  }

  String _fmt(Duration d) {
    final s = d.inSeconds;
    final m = (s ~/ 60).toString();
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final total = _total.inMilliseconds == 0 ? widget.totalHint : _total;
    final progress = total.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
    final playedCount = (_heights.length * progress).round();

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF3E3E3E),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF999999),
                  width: 0.35,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                _playing
                    ? PhosphorIcons.pause(PhosphorIconsStyle.fill)
                    : PhosphorIcons.play(PhosphorIconsStyle.fill),
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 15,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3E3E3E),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var i = 0; i < _heights.length; i++)
                          Container(
                            width: 2,
                            height: _heights[i].toDouble(),
                            decoration: BoxDecoration(
                              color: i < playedCount ? _played : _unplayed,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_fmt(_position)} / ${_fmt(total)}',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
              color: _meta,
            ),
          ),
          if (widget.onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: widget.onClose,
              behavior: HitTestBehavior.opaque,
              child: const Icon(Icons.close, size: 16, color: _meta),
            ),
          ],
        ],
      ),
    );
  }
}

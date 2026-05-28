import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class TimeTravelBar extends StatefulWidget {
  final int minYear;
  final int maxYear;
  final int initialYear;
  final ValueChanged<int>? onYearChanged;

  const TimeTravelBar({
    super.key,
    this.minYear = 1920,
    this.maxYear = 2026,
    this.initialYear = 2026,
    this.onYearChanged,
  });

  @override
  State<TimeTravelBar> createState() => _TimeTravelBarState();
}

class _TimeTravelBarState extends State<TimeTravelBar> {
  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Line.
        Positioned(
          left: 16.75,
          right: 16.75,
          top: 10,
          child: Container(
            height: 2,
            color: const Color(0xFF999999),
          ),
        ),
        // Slider over line.
        Positioned(
          left: 8,
          right: 8,
          top: 0,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 0,
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: Colors.transparent,
              inactiveTrackColor: Colors.transparent,
              thumbShape: const _YearThumbShape(),
            ),
            child: Slider(
              min: widget.minYear.toDouble(),
              max: widget.maxYear.toDouble(),
              value: _year.toDouble(),
              onChanged: (v) {
                setState(() => _year = v.round());
                widget.onYearChanged?.call(_year);
              },
            ),
          ),
        ),
        // Min label.
        Positioned(
          left: 15,
          top: 29,
          child: Text('${widget.minYear}', style: _labelStyle),
        ),
        // Max label.
        Positioned(
          right: 15,
          top: 29,
          child: Text('${widget.maxYear}', style: _labelStyle),
        ),
        // Time travel label + sparkle.
        Positioned(
          left: 14,
          top: 1,
          child: Row(
            children: [
              Icon(
                PhosphorIcons.sparkle(PhosphorIconsStyle.fill),
                size: 10,
                color: const Color(0xFFA07A23),
                shadows: const [
                  Shadow(
                    color: Color(0xFFF6D046),
                    blurRadius: 8.4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              const SizedBox(width: 2),
              const Text(
                'TIME TRAVEL',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10,
                  height: 13 / 10,
                  color: Color(0xFF1D1E09),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'DM Sans',
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: -0.24,
    color: Color(0xFF5F5F5F),
  );
}

class _YearThumbShape extends SliderComponentShape {
  const _YearThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => const Size(21, 21);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4
      ..color = const Color(0xFFA07A23);
    final dot = Paint()..color = const Color(0xFFA07A23);
    canvas.drawCircle(center, 10.5, ring);
    canvas.drawCircle(center, 6.5, dot);
  }
}

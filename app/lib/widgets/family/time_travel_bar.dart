import 'package:flutter/material.dart';

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

  static const double _thumbRadius = 9;
  static const double _ringRadius = 12;
  static const double _trackHeight = 2;
  static const double _hPad = 16;

  @override
  void initState() {
    super.initState();
    _year = widget.initialYear;
  }

  void _updateFromDx(double dx, double width) {
    final t = (dx / width).clamp(0.0, 1.0);
    final y = widget.minYear + ((widget.maxYear - widget.minYear) * t).round();
    if (y != _year) {
      setState(() => _year = y);
      widget.onYearChanged?.call(_year);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_hPad, 6, _hPad, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: const [
              Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: Color(0xFF5F5F5F),
              ),
              SizedBox(width: 4),
              Text(
                'TIME TRAVEL',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 10,
                  height: 1.0,
                  letterSpacing: 0.2,
                  color: Color(0xFF444444),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LayoutBuilder(
            builder: (context, c) {
              final width = c.maxWidth;
              final t = (_year - widget.minYear) /
                  (widget.maxYear - widget.minYear);
              final thumbX = (t * width).clamp(0.0, width);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (d) =>
                    _updateFromDx(d.localPosition.dx, width),
                onHorizontalDragUpdate: (d) =>
                    _updateFromDx(d.localPosition.dx, width),
                onTapDown: (d) => _updateFromDx(d.localPosition.dx, width),
                child: SizedBox(
                  height: _ringRadius * 2,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: _ringRadius - _trackHeight / 2,
                        child: Container(
                          height: _trackHeight,
                          color: const Color(0xFF999999),
                        ),
                      ),
                      Positioned(
                        left: thumbX - _ringRadius,
                        top: 0,
                        child: Container(
                          width: _ringRadius * 2,
                          height: _ringRadius * 2,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFB88924),
                            border: Border.all(
                              color: const Color(0xFFE5D2A3),
                              width: _ringRadius - _thumbRadius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${widget.minYear}', style: _labelStyle),
              Text('${widget.maxYear}', style: _labelStyle),
            ],
          ),
        ],
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'DM Sans',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.0,
    letterSpacing: -0.24,
    color: Color(0xFF666666),
  );
}

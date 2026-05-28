import 'package:flutter/material.dart';

class DotGridBackground extends StatelessWidget {
  final Color dotColor;
  final double dotSize;
  final double gap;

  const DotGridBackground({
    super.key,
    this.dotColor = const Color(0xFFD3D2CE),
    this.dotSize = 3,
    this.gap = 32,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DotGridPainter(
        dotColor: dotColor,
        dotSize: dotSize,
        gap: gap,
      ),
      size: Size.infinite,
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color dotColor;
  final double dotSize;
  final double gap;

  _DotGridPainter({
    required this.dotColor,
    required this.dotSize,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    final step = dotSize + gap;
    final radius = dotSize / 2;
    final startX = 6.0;
    final startY = 6.0;
    for (double y = startY; y < size.height; y += step) {
      for (double x = startX; x < size.width; x += step) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter old) =>
      old.dotColor != dotColor || old.dotSize != dotSize || old.gap != gap;
}

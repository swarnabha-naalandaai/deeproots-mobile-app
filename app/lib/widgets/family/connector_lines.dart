import 'package:flutter/material.dart';

/// Paints family tree blood-relation connectors with rounded corners and
/// short vertical stubs above each child node — matches Figma.
class ConnectorLines extends StatelessWidget {
  const ConnectorLines({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ConnectorPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  static const Color stroke = Color(0xFF5F5F5F);

  static const double gpCenterY = 205.5;
  static const double parentCenterY = 372;
  static const double siblingTopY = 485;

  static const double anantCx = -41 + 38;
  static const double prernaCx = 97 + 38;
  static const double fatherCx = 251 + 38;
  static const double motherCx = 391 + 38;
  static const double ashishCx = 107 + 38;
  static const double aparnaCx = 240 + 38;

  static const double avatarHalf = 38;

  // Corner radius + stub above child nodes.
  static const double r = 10;
  static const double stub = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final gp1Right = anantCx + avatarHalf;
    final gp1Left = prernaCx - avatarHalf;
    final gp1Mid = (gp1Right + gp1Left) / 2;
    final gp2Right = fatherCx + avatarHalf;
    final gp2Left = motherCx - avatarHalf;
    final gp2Mid = (gp2Right + gp2Left) / 2;

    final parentsRight = ashishCx + avatarHalf;
    final parentsLeft = aparnaCx - avatarHalf;
    final parentsMid = (parentsRight + parentsLeft) / 2;

    final parentBarY = parentCenterY - avatarHalf - stub; // child stub bar
    final sibBarY = siblingTopY - 20;

    // 1. Anant ↔ Prerna couple bar + curved drop to Ashish (with stub).
    canvas.drawLine(Offset(gp1Right, gpCenterY), Offset(gp1Left, gpCenterY), paint);
    canvas.drawPath(
      _route([
        Offset(gp1Mid, gpCenterY),
        Offset(gp1Mid, parentBarY),
        Offset(ashishCx, parentBarY),
        Offset(ashishCx, parentCenterY - avatarHalf),
      ]),
      paint,
    );

    // 2. Father ↔ Mother couple bar + curved drop to Aparna.
    canvas.drawLine(Offset(gp2Right, gpCenterY), Offset(gp2Left, gpCenterY), paint);
    canvas.drawPath(
      _route([
        Offset(gp2Mid, gpCenterY),
        Offset(gp2Mid, parentBarY),
        Offset(aparnaCx, parentBarY),
        Offset(aparnaCx, parentCenterY - avatarHalf),
      ]),
      paint,
    );

    // 3. Ashish ↔ Aparna couple bar.
    canvas.drawLine(Offset(parentsRight, parentCenterY), Offset(parentsLeft, parentCenterY), paint);

    // 4. Drop from parents midpoint to sibling bar — two curved arms (one per child).
    canvas.drawPath(
      _route([
        Offset(parentsMid, parentCenterY),
        Offset(parentsMid, sibBarY),
        Offset(ashishCx, sibBarY),
        Offset(ashishCx, siblingTopY),
      ]),
      paint,
    );
    canvas.drawPath(
      _route([
        Offset(parentsMid, parentCenterY),
        Offset(parentsMid, sibBarY),
        Offset(aparnaCx, sibBarY),
        Offset(aparnaCx, siblingTopY + 2),
      ]),
      paint,
    );
  }

  // Build a path through waypoints, rounding each interior corner with radius `r`.
  Path _route(List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length - 1; i++) {
      final prev = pts[i - 1];
      final c = pts[i];
      final next = pts[i + 1];
      final v1 = prev - c;
      final v2 = next - c;
      final d1 = v1.distance;
      final d2 = v2.distance;
      final rr = _min3(r, d1 / 2, d2 / 2);
      final p1 = c + v1 * (rr / d1);
      final p2 = c + v2 * (rr / d2);
      path.lineTo(p1.dx, p1.dy);
      path.quadraticBezierTo(c.dx, c.dy, p2.dx, p2.dy);
    }
    path.lineTo(pts.last.dx, pts.last.dy);
    return path;
  }

  double _min3(double a, double b, double c) => a < b ? (a < c ? a : c) : (b < c ? b : c);

  @override
  bool shouldRepaint(covariant _ConnectorPainter old) => false;
}

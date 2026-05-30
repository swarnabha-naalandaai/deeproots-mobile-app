import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/family_tree_state.dart';

class ConnectorLines extends StatelessWidget {
  final FamilyTreeState state;
  final Map<String, Position> positions;
  final double nodeW;
  final double nodeH;
  final Set<String> lineageIds;

  const ConnectorLines({
    super.key,
    required this.state,
    required this.positions,
    this.nodeW = 110.0,
    this.nodeH = 114.0,
    this.lineageIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _DynamicConnectorPainter(
          state: state,
          positions: positions,
          nodeW: nodeW,
          nodeH: nodeH,
          lineageIds: lineageIds,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _Group {
  final List<String> parents;
  final List<String> children;
  _Group(this.parents, this.children);
}

class _DynamicConnectorPainter extends CustomPainter {
  final FamilyTreeState state;
  final Map<String, Position> positions;
  final double nodeW;
  final double nodeH;
  final Set<String> lineageIds;

  static const Color _lineColor = Color(0xFF5F5F5F);
  static const Color _lineageColor = Color(0xFFA07A23);

  _DynamicConnectorPainter({
    required this.state,
    required this.positions,
    required this.nodeW,
    required this.nodeH,
    required this.lineageIds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty) return;

    // 1. Paint Partner / Spouse horizontal lines
    final paintedSpouses = <String>{};

    for (final pair in state.partners) {
      final a = pair[0];
      final b = pair[1];
      if (paintedSpouses.contains('$a-$b') || paintedSpouses.contains('$b-$a')) continue;
      
      final pa = positions[a];
      final pb = positions[b];
      if (pa == null || pb == null) continue;

      final y = pa.y + nodeH / 2;
      final x1 = min(pa.x, pb.x) + (nodeW - 76) / 2 + 76;
      final x2 = max(pa.x, pb.x) + (nodeW - 76) / 2;

      if (x2 > x1) {
        final isLineageEdge = lineageIds.contains(a) && lineageIds.contains(b);
        canvas.drawLine(Offset(x1, y), Offset(x2, y), Paint()
          ..color = isLineageEdge ? _lineageColor : _lineColor
          ..strokeWidth = isLineageEdge ? 2.0 : 1.5
          ..style = PaintingStyle.stroke);
        paintedSpouses.add('$a-$b');
      }
    }

    // 2. Paint Parent-Child orthogonal tree lines
    // Group children by their set of parents
    final c2p = <String, Set<String>>{};
    for (final pc in state.parentChild) {
      final parent = pc[0];
      final child = pc[1];
      c2p.putIfAbsent(child, () => <String>{}).add(parent);
    }

    final groups = <String, _Group>{};
    c2p.forEach((child, parentsSet) {
      final parents = parentsSet.toList()..sort();
      final sig = parents.join("|");
      groups.putIfAbsent(sig, () => _Group(parents, [])).children.add(child);
    });

    final linePaint = Paint()
      ..color = _lineColor
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final lineagePaint = Paint()
      ..color = _lineageColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    const double cornerR = 8.0;

    groups.forEach((sig, g) {
      final px = g.parents.map((p) => positions[p]).whereType<Position>().toList();
      if (px.isEmpty) return;

      double aX;
      double aY;
      if (px.length == 1) {
        aX = px[0].x + nodeW / 2;
        aY = px[0].y + nodeH;
      } else {
        final l = px.map((p) => p.x).reduce(min);
        final r = px.map((p) => p.x + nodeW).reduce(max);
        aX = (l + r) / 2;
        aY = px[0].y + nodeH / 2; // couple midpoint Y
      }

      final cps = g.children.map((c) => positions[c]).whereType<Position>().toList();
      if (cps.isEmpty) return;

      final tcy = cps[0].y;
      final my = (aY + tcy) / 2;

      final cx = cps.map((p) => p.x + nodeW / 2).toList();

      // Draw a unified, continuous path of 4 points for each child to enable rounded corner curves
      for (var i = 0; i < cx.length; i++) {
        final childId = g.children[i];
        final childInLineage = lineageIds.contains(childId);
        final anyParentInLineage = g.parents.any(lineageIds.contains);
        final isLineageEdge = childInLineage && anyParentInLineage;
        _drawRoutedPath(
          canvas,
          [
            Offset(aX, aY),
            Offset(aX, my),
            Offset(cx[i], my),
            Offset(cx[i], cps[i].y),
          ],
          isLineageEdge ? lineagePaint : linePaint,
          cornerR,
        );
      }
    });
  }



  void _drawRoutedPath(
    Canvas canvas,
    List<Offset> pts,
    Paint paint,
    double r,
  ) {
    if (pts.length < 2) return;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    
    for (var i = 1; i < pts.length - 1; i++) {
      final prev = pts[i - 1];
      final c = pts[i];
      final next = pts[i + 1];
      final v1 = prev - c;
      final v2 = next - c;
      final d1 = v1.distance;
      final d2 = v2.distance;
      if (d1 == 0 || d2 == 0) {
        path.lineTo(c.dx, c.dy);
        continue;
      }
      final rr = _min3(r, d1 / 2, d2 / 2);
      final p1 = c + v1 * (rr / d1);
      final p2 = c + v2 * (rr / d2);
      path.lineTo(p1.dx, p1.dy);
      path.quadraticBezierTo(c.dx, c.dy, p2.dx, p2.dy);
    }
    
    path.lineTo(pts.last.dx, pts.last.dy);
    canvas.drawPath(path, paint);
  }

  double _min3(double a, double b, double c) =>
      a < b ? (a < c ? a : c) : (b < c ? b : c);

  @override
  bool shouldRepaint(covariant _DynamicConnectorPainter old) =>
      old.state != state ||
      old.positions != positions ||
      old.lineageIds != lineageIds;
}

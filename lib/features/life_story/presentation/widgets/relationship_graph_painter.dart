import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/relationship_node_model.dart';

class RelationshipGraphPainter extends CustomPainter {
  final List<RelationshipNode> nodes;
  final List<RelationshipEdge> edges;
  final RelationshipNode? selectedNode;
  final double animationProgress;

  RelationshipGraphPainter({
    required this.nodes,
    required this.edges,
    this.selectedNode,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.44);
    final graphRadius = min(size.width * 0.46, size.height * 0.38);

    // 1. Draw Central Patient Glowing Concentric Circles
    _paintCenterGlow(canvas, center);

    // 2. Draw Secondary Dashed Arcs between outer nodes
    _paintDashedArcs(canvas, center, graphRadius);

    // 3. Draw Primary Connection Edges & Labels from Center to Nodes
    _paintRadialEdges(canvas, center, graphRadius);

    // 4. Draw Center Node Circle
    _paintCenterNode(canvas, center);

    // 5. Draw Outer Entity Nodes
    _paintNodes(canvas, center, graphRadius);
  }

  void _paintCenterGlow(Canvas canvas, Offset center) {
    // Outer translucent green halo
    final outerHalo = Paint()
      ..color = const Color(0xFF2EAA55).withValues(alpha: 0.12 * animationProgress)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 78, outerHalo);

    // Middle brighter green halo
    final middleHalo = Paint()
      ..color = const Color(0xFF2EAA55).withValues(alpha: 0.22 * animationProgress)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 54, middleHalo);
  }

  void _paintCenterNode(Canvas canvas, Offset center) {
    // Center background circle
    final bgPaint = Paint()
      ..color = const Color(0xFF0F325E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 34, bgPaint);

    // Center white ring
    final ringPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, 34, ringPaint);

    // Inner radiating spoke lines inside center node
    final spokePaint = Paint()
      ..color = const Color(0xFF2EAA55).withValues(alpha: 0.7)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 6; i++) {
      final angle = i * (pi / 3);
      final spokeEnd = Offset(center.dx + 30 * cos(angle), center.dy + 30 * sin(angle));
      canvas.drawLine(center, spokeEnd, spokePaint);
    }
  }

  void _paintRadialEdges(Canvas canvas, Offset center, double graphRadius) {
    for (final edge in edges) {
      if (edge.isDashed) continue;

      final targetNode = nodes.firstWhere(
        (n) => n.id == edge.targetNodeId,
        orElse: () => nodes.first,
      );

      final nodePos = _getNodePosition(center, targetNode, graphRadius);

      final isSelectedEdge = selectedNode != null && targetNode.id == selectedNode!.id;

      // Draw Connection Line
      final linePaint = Paint()
        ..color = isSelectedEdge ? const Color(0xFF48BB78) : const Color(0xFF2EAA55).withValues(alpha: 0.85)
        ..strokeWidth = isSelectedEdge ? 2.8 : 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, nodePos, linePaint);

      // Draw Edge Label along the line
      if (edge.label.isNotEmpty) {
        final mid = Offset(
          center.dx + (nodePos.dx - center.dx) * 0.52,
          center.dy + (nodePos.dy - center.dy) * 0.52,
        );

        final textSpan = TextSpan(
          text: edge.label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            shadows: const [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        // Slight offset depending on quadrant for perfect readability
        double offsetX = -textPainter.width / 2;
        double offsetY = -textPainter.height / 2;

        if (nodePos.dx < center.dx) {
          offsetX -= 8;
        } else {
          offsetX += 8;
        }

        textPainter.paint(canvas, Offset(mid.dx + offsetX, mid.dy + offsetY));
      }
    }
  }

  void _paintDashedArcs(Canvas canvas, Offset center, double graphRadius) {
    for (final edge in edges) {
      if (!edge.isDashed) continue;

      final sourceNode = nodes.cast<RelationshipNode?>().firstWhere(
            (n) => n?.id == edge.sourceNodeId,
            orElse: () => null,
          );
      final targetNode = nodes.cast<RelationshipNode?>().firstWhere(
            (n) => n?.id == edge.targetNodeId,
            orElse: () => null,
          );

      if (sourceNode == null || targetNode == null) continue;

      final pos1 = _getNodePosition(center, sourceNode, graphRadius);
      final pos2 = _getNodePosition(center, targetNode, graphRadius);

      // Quadratic bezier curved arc bowing outward
      final mid = Offset((pos1.dx + pos2.dx) / 2, (pos1.dy + pos2.dy) / 2);
      final dir = Offset(mid.dx - center.dx, mid.dy - center.dy);
      final dist = sqrt(dir.dx * dir.dx + dir.dy * dir.dy);
      final controlPoint = dist > 0
          ? Offset(mid.dx + (dir.dx / dist) * 28, mid.dy + (dir.dy / dist) * 28)
          : mid;

      final path = Path()
        ..moveTo(pos1.dx, pos1.dy)
        ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, pos2.dx, pos2.dy);

      _drawDashedPath(canvas, path, const Color(0xFF60A5FA).withValues(alpha: 0.45));
    }
  }

  void _paintNodes(Canvas canvas, Offset center, double graphRadius) {
    for (final node in nodes) {
      final pos = _getNodePosition(center, node, graphRadius);
      final isSelected = selectedNode != null && selectedNode!.id == node.id;
      const radius = 28.0;

      // 1. Highlight pulse for selected node
      if (isSelected) {
        final glowPaint = Paint()
          ..color = (node.type == RelationshipNodeType.person
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFF48BB78))
              .withValues(alpha: 0.38)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, radius + 10, glowPaint);
      }

      // 2. Node Shape depending on Type:
      switch (node.type) {
        // A) Person Node: Blue Ring Outline with stylized avatar inside
        case RelationshipNodeType.person:
          // Translucent dark background fill
          canvas.drawCircle(
            pos,
            radius,
            Paint()..color = const Color(0xFF0A294E).withValues(alpha: 0.8),
          );

          // Blue outline ring
          final ringPaint = Paint()
            ..color = const Color(0xFF2563EB)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.2;
          canvas.drawCircle(pos, radius, ringPaint);

          // Stylized Avatar icon inside
          _paintPersonAvatar(canvas, pos, radius);
          break;

        // B) Place Node: Solid Dark Green Circle with White Text
        case RelationshipNodeType.place:
          final bgPaint = Paint()
            ..color = const Color(0xFF1E6B38)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, radius, bgPaint);

          // Subtle white border
          final borderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;
          canvas.drawCircle(pos, radius, borderPaint);

          _paintNodeText(canvas, pos, node.name);
          break;

        // C) Event Node: Solid Lime Green Circle with White Text
        case RelationshipNodeType.event:
          final bgPaint = Paint()
            ..color = const Color(0xFF58C97A)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, radius, bgPaint);

          // Subtle white border
          final borderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;
          canvas.drawCircle(pos, radius, borderPaint);

          _paintNodeText(canvas, pos, node.name);
          break;
      }
    }
  }

  void _paintPersonAvatar(Canvas canvas, Offset center, double radius) {
    // Head circle (Cream/Peach)
    final headCenter = Offset(center.dx, center.dy - radius * 0.18);
    final headRadius = radius * 0.34;
    canvas.drawCircle(headCenter, headRadius, Paint()..color = const Color(0xFFFDE68A));

    // Torso / Shoulders arc (Green or Slate)
    final bodyPaint = Paint()..color = const Color(0xFF2EAA55);
    final bodyPath = Path()
      ..moveTo(center.dx - radius * 0.58, center.dy + radius * 0.65)
      ..quadraticBezierTo(
        center.dx,
        center.dy + radius * 0.15,
        center.dx + radius * 0.58,
        center.dy + radius * 0.65,
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius - 2),
        0.5,
        2.14,
        false,
      )
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);
  }

  void _paintNodeText(Canvas canvas, Offset center, String text) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12.5,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black45, blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 52);

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  Offset _getNodePosition(Offset center, RelationshipNode node, double graphRadius) {
    return Offset(
      center.dx + node.relativePosition.dx * graphRadius,
      center.dy + node.relativePosition.dy * graphRadius,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      const dashLength = 5.0;
      const dashSpace = 4.0;
      while (distance < metric.length) {
        final next = min(distance + dashLength, metric.length);
        final segment = metric.extractPath(distance, next);
        canvas.drawPath(segment, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant RelationshipGraphPainter oldDelegate) {
    return oldDelegate.selectedNode != selectedNode ||
        oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges ||
        oldDelegate.animationProgress != animationProgress;
  }
}

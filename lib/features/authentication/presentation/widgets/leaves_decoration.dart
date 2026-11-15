import 'dart:math' as math;
import 'package:flutter/material.dart';

class LeavesDecoration extends StatelessWidget {
  const LeavesDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: double.infinity,
        height: 140,
        child: CustomPaint(
          painter: _LeavesPainter(),
        ),
      ),
    );
  }
}

class _LeavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background Soft Horizon Wave
    final wavePaint = Paint()
      ..color = const Color(0xFFE3F4EA).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final wavePath = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.4,
        size.width,
        size.height * 0.6,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wavePath, wavePaint);

    final wavePaint2 = Paint()
      ..color = const Color(0xFFCCEBD9).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    final wavePath2 = Path()
      ..moveTo(0, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.55,
        size.width,
        size.height * 0.8,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wavePath2, wavePaint2);

    // Left Leaf Branch
    _drawLeafBranch(
      canvas,
      basePoint: Offset(size.width * 0.08, size.height),
      angle: -0.3,
      scale: 0.9,
      leafColor: const Color(0xFF90D6B1),
      accentColor: const Color(0xFF67C292),
    );

    _drawLeafBranch(
      canvas,
      basePoint: Offset(0, size.height * 0.9),
      angle: 0.2,
      scale: 0.7,
      leafColor: const Color(0xFFA5DFC0),
      accentColor: const Color(0xFF7BCE9F),
    );

    // Right Leaf Branch
    _drawLeafBranch(
      canvas,
      basePoint: Offset(size.width * 0.92, size.height),
      angle: 0.3,
      scale: 1.0,
      leafColor: const Color(0xFF81D1A6),
      accentColor: const Color(0xFF55BA83),
    );

    _drawLeafBranch(
      canvas,
      basePoint: Offset(size.width, size.height * 0.85),
      angle: -0.15,
      scale: 0.75,
      leafColor: const Color(0xFF9EE1BD),
      accentColor: const Color(0xFF75CE9F),
    );
  }

  void _drawLeafBranch(
    Canvas canvas, {
    required Offset basePoint,
    required double angle,
    required double scale,
    required Color leafColor,
    required Color accentColor,
  }) {
    canvas.save();
    canvas.translate(basePoint.dx, basePoint.dy);
    canvas.rotate(angle);
    canvas.scale(scale);

    final stemPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(0, -50, 10, -90);

    canvas.drawPath(stemPath, stemPaint);

    // Leaves along stem
    final leafOffsets = [
      const Offset(0, -20),
      const Offset(3, -40),
      const Offset(6, -60),
      const Offset(9, -80),
      const Offset(10, -90),
    ];

    final leafPaint = Paint()
      ..color = leafColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < leafOffsets.length; i++) {
      final pos = leafOffsets[i];
      final isTop = i == leafOffsets.length - 1;

      if (isTop) {
        _drawSingleLeaf(canvas, pos, -math.pi / 2, 16, 8, leafPaint);
      } else {
        _drawSingleLeaf(canvas, pos, -math.pi / 4, 18, 9, leafPaint);
        _drawSingleLeaf(canvas, pos, -3 * math.pi / 4, 18, 9, leafPaint);
      }
    }

    canvas.restore();
  }

  void _drawSingleLeaf(
    Canvas canvas,
    Offset origin,
    double angle,
    double length,
    double width,
    Paint paint,
  ) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);

    final leafPath = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(width, -length * 0.5, 0, -length)
      ..quadraticBezierTo(-width, -length * 0.5, 0, 0)
      ..close();

    canvas.drawPath(leafPath, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';

class GoogleLogoIcon extends StatelessWidget {
  final double size;

  const GoogleLogoIcon({
    super.key,
    this.size = 22.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Offset center = Offset(w / 2, h / 2);
    final double radius = w / 2;

    final redPaint = Paint()..color = const Color(0xFFEA4335);
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    final bluePaint = Paint()..color = const Color(0xFF4285F4);

    final double strokeWidth = radius * 0.42;

    // Red Arc (Top)
    final redPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -1.35,
        1.55,
      );
    canvas.drawPath(
      redPath,
      redPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Yellow Arc (Bottom-Left)
    final yellowPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        0.2,
        1.55,
      );
    canvas.drawPath(
      yellowPath,
      yellowPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Green Arc (Bottom)
    final greenPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        1.75,
        1.55,
      );
    canvas.drawPath(
      greenPath,
      greenPaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Blue Bar & Arc (Right)
    final bluePath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        -0.4,
        0.6,
      );
    canvas.drawPath(
      bluePath,
      bluePaint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Blue Center Bar
    final barRect = Rect.fromLTWH(
      center.dx,
      center.dy - strokeWidth / 2,
      radius,
      strokeWidth,
    );
    canvas.drawRect(barRect, bluePaint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

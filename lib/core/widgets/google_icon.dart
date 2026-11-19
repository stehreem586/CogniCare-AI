import 'package:flutter/material.dart';

/// Pixel-perfect, official Google 'G' brand logo icon.
///
/// Efficiently rendered using exact vector Bézier curves in a canonical
/// 48x48 viewport, scaled cleanly with anti-aliasing to any requested [size].
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
        painter: const _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  // Official Google brand colors
  static const Color _red = Color(0xFFEA4335);
  static const Color _yellow = Color(0xFFFBBC05);
  static const Color _green = Color(0xFF34A853);
  static const Color _blue = Color(0xFF4285F4);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    canvas.save();
    // Scale canonical 48x48 vector space to target canvas dimensions
    canvas.scale(size.width / 48.0, size.height / 48.0);

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    // 1. Blue Segment (Right Bar and upper quadrant hook)
    final Path bluePath = Path()
      ..moveTo(46.98, 24.55)
      ..cubicTo(46.98, 22.98, 46.83, 21.46, 46.60, 20.0)
      ..lineTo(24.0, 20.0)
      ..lineTo(24.0, 29.02)
      ..lineTo(36.94, 29.02)
      ..cubicTo(36.36, 31.98, 34.68, 34.50, 32.16, 36.20)
      ..lineTo(39.89, 42.20)
      ..cubicTo(44.40, 38.02, 46.98, 31.84, 46.98, 24.55)
      ..close();
    paint.color = _blue;
    canvas.drawPath(bluePath, paint);

    // 2. Green Segment (Bottom arc)
    final Path greenPath = Path()
      ..moveTo(24.0, 48.0)
      ..cubicTo(30.48, 48.0, 35.93, 45.87, 39.89, 42.20)
      ..lineTo(32.16, 36.20)
      ..cubicTo(30.01, 37.65, 27.24, 38.50, 24.0, 38.50)
      ..cubicTo(17.74, 38.50, 12.43, 34.28, 10.53, 28.59)
      ..lineTo(2.55, 34.78)
      ..cubicTo(6.51, 42.62, 14.62, 48.0, 24.0, 48.0)
      ..close();
    paint.color = _green;
    canvas.drawPath(greenPath, paint);

    // 3. Yellow Segment (Lower-left arc)
    final Path yellowPath = Path()
      ..moveTo(10.53, 28.59)
      ..cubicTo(10.05, 27.14, 9.77, 25.60, 9.77, 24.0)
      ..cubicTo(9.77, 22.40, 10.05, 20.86, 10.53, 19.41)
      ..lineTo(2.55, 13.22)
      ..cubicTo(0.92, 16.46, 0.0, 20.12, 0.0, 24.0)
      ..cubicTo(0.0, 27.88, 0.92, 31.54, 2.55, 34.78)
      ..lineTo(10.53, 28.59)
      ..close();
    paint.color = _yellow;
    canvas.drawPath(yellowPath, paint);

    // 4. Red Segment (Top arc)
    final Path redPath = Path()
      ..moveTo(24.0, 9.50)
      ..cubicTo(27.54, 9.50, 30.71, 10.72, 33.21, 13.10)
      ..lineTo(40.06, 6.25)
      ..cubicTo(35.90, 2.38, 30.47, 0.0, 24.0, 0.0)
      ..cubicTo(14.62, 0.0, 6.51, 5.38, 2.55, 13.22)
      ..lineTo(10.53, 19.41)
      ..cubicTo(12.43, 13.72, 17.74, 9.50, 24.0, 9.50)
      ..close();
    paint.color = _red;
    canvas.drawPath(redPath, paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


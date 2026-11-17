import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/therapy_colors.dart';

class TherapyBrandMark extends StatelessWidget {
  const TherapyBrandMark({super.key, this.size = 42});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7DE3C2), Color(0xFF2EC4A0)],
        ),
        boxShadow: [
          BoxShadow(
            color: TherapyColors.teal.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(Icons.favorite_rounded, color: Colors.white, size: size * 0.48),
    );
  }
}

class MountainLakeScene extends StatelessWidget {
  const MountainLakeScene({
    super.key,
    this.showMissingPiece = false,
    this.borderRadius = 22,
  });

  final bool showMissingPiece;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CustomPaint(
        painter: _MountainLakePainter(showMissingPiece: showMissingPiece),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MountainLakePainter extends CustomPainter {
  _MountainLakePainter({required this.showMissingPiece});

  final bool showMissingPiece;

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF9ED8F8), Color(0xFFD8F0FC), Color(0xFFB8E4C8)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final sun = Paint()..color = const Color(0xFFFFF2B0).withValues(alpha: 0.9);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.22), 16, sun);

    _mountain(canvas, size, const Color(0xFF7FB8D8), 0.42, [
      Offset(0, size.height * 0.55),
      Offset(size.width * 0.22, size.height * 0.28),
      Offset(size.width * 0.48, size.height * 0.58),
    ]);
    _mountain(canvas, size, const Color(0xFF5A9BC4), 0.5, [
      Offset(size.width * 0.28, size.height * 0.62),
      Offset(size.width * 0.55, size.height * 0.22),
      Offset(size.width * 0.82, size.height * 0.6),
    ]);
    _mountain(canvas, size, const Color(0xFF3F7FA8), 0.58, [
      Offset(size.width * 0.58, size.height * 0.62),
      Offset(size.width * 0.88, size.height * 0.26),
      Offset(size.width, size.height * 0.55),
    ]);

    final lake = Path()
      ..moveTo(0, size.height * 0.58)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width,
        size.height * 0.6,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      lake,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [Color(0xFF6EC4E8), Color(0xFF3FA0C8)],
        ).createShader(Offset.zero & size),
    );

    final shore = Paint()..color = const Color(0xFF7BC47A);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.22, size.height * 0.78),
        width: size.width * 0.55,
        height: size.height * 0.28,
      ),
      shore,
    );

    _tree(canvas, Offset(size.width * 0.12, size.height * 0.72), 22);
    _tree(canvas, Offset(size.width * 0.22, size.height * 0.74), 18);
    _tree(canvas, Offset(size.width * 0.78, size.height * 0.7), 20);

    if (showMissingPiece) {
      final piece = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, size.height * 0.08, size.width * 0.26, size.height * 0.34),
        const Radius.circular(8),
      );
      canvas.drawRRect(piece, Paint()..color = Colors.white.withValues(alpha: 0.96));
      canvas.drawRRect(
        piece,
        Paint()
          ..color = const Color(0xFFD7E6F2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }
  }

  void _mountain(Canvas canvas, Size size, Color color, double peakY, List<Offset> pts) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    path.lineTo(pts.last.dx, size.height * 0.7);
    path.lineTo(pts.first.dx, size.height * 0.7);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
    final snow = Path()
      ..moveTo(pts[1].dx - 18, pts[1].dy + 22)
      ..lineTo(pts[1].dx, pts[1].dy)
      ..lineTo(pts[1].dx + 16, pts[1].dy + 20)
      ..close();
    canvas.drawPath(snow, Paint()..color = Colors.white.withValues(alpha: 0.85));
  }

  void _tree(Canvas canvas, Offset base, double h) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: base, width: 5, height: h * 0.35),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF8B5A3C),
    );
    canvas.drawCircle(
      base.translate(0, -h * 0.35),
      h * 0.38,
      Paint()..color = const Color(0xFF3FA36A),
    );
  }

  @override
  bool shouldRepaint(covariant _MountainLakePainter oldDelegate) =>
      oldDelegate.showMissingPiece != showMissingPiece;
}

class ParkMemoryScene extends StatelessWidget {
  const ParkMemoryScene({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: CustomPaint(
        painter: _ParkPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ParkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8EC8F0), Color(0xFFC8E8A8), Color(0xFF8FCB70)],
        ).createShader(Offset.zero & size),
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.18),
      22,
      Paint()..color = const Color(0xFFFFF0B0),
    );

    _tree(canvas, Offset(size.width * 0.18, size.height * 0.62), 70);
    _tree(canvas, Offset(size.width * 0.34, size.height * 0.7), 54);

    final path = Path()
      ..moveTo(size.width * 0.35, size.height)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.7, size.width * 0.95, size.height * 0.78);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFD9C08A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round,
    );

    final benchY = size.height * 0.78;
    final benchX = size.width * 0.58;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(benchX, benchY, 86, 10),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFF8B5A2B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(benchX + 4, benchY - 18, 78, 8),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFA06A32),
    );
    canvas.drawRect(Rect.fromLTWH(benchX + 8, benchY + 8, 6, 16), Paint()..color = const Color(0xFF6B4423));
    canvas.drawRect(Rect.fromLTWH(benchX + 72, benchY + 8, 6, 16), Paint()..color = const Color(0xFF6B4423));
  }

  void _tree(Canvas canvas, Offset base, double h) {
    canvas.drawRect(
      Rect.fromCenter(center: base, width: 10, height: h * 0.4),
      Paint()..color = const Color(0xFF7A4A28),
    );
    canvas.drawOval(
      Rect.fromCenter(center: base.translate(0, -h * 0.38), width: h * 0.7, height: h * 0.72),
      Paint()..color = const Color(0xFF2F8A4A),
    );
    canvas.drawOval(
      Rect.fromCenter(center: base.translate(-12, -h * 0.22), width: h * 0.5, height: h * 0.45),
      Paint()..color = const Color(0xFF3FA35C),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MiniPuzzlePiece extends StatelessWidget {
  const MiniPuzzlePiece({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.variant,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int variant;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 68,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? TherapyColors.primary : const Color(0xFFD7E4F0),
                width: selected ? 2.4 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: TherapyColors.primary.withValues(alpha: 0.18),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomPaint(painter: _PuzzleThumbPainter(variant: variant)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? TherapyColors.navy : TherapyColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _PuzzleThumbPainter extends CustomPainter {
  _PuzzleThumbPainter({required this.variant});

  final int variant;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const [Color(0xFF6EC4E8), Color(0xFF3FA0C8)],
      const [Color(0xFF8FCB70), Color(0xFF5AA64A)],
      const [Color(0xFF5A9BC4), Color(0xFF9ED8F8)],
      const [Color(0xFF7BC47A), Color(0xFF3FA36A)],
    ][variant % 4];
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(Offset.zero & size),
    );
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.4),
      10,
      Paint()..color = Colors.white.withValues(alpha: 0.25),
    );
  }

  @override
  bool shouldRepaint(covariant _PuzzleThumbPainter oldDelegate) =>
      oldDelegate.variant != variant;
}

class MoodTrendChart extends StatelessWidget {
  const MoodTrendChart({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MoodChartPainter(),
      child: const SizedBox(height: 150, width: double.infinity),
    );
  }
}

class _MoodChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [0.55, 0.62, 0.48, 0.72, 0.58, 0.8, 0.7];
    final chart = Rect.fromLTWH(8, 8, size.width - 16, size.height - 28);
    final dx = chart.width / (values.length - 1);

    final path = Path();
    final fill = Path();
    for (var i = 0; i < values.length; i++) {
      final x = chart.left + dx * i;
      final y = chart.bottom - values[i] * chart.height;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, chart.bottom);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(chart.right, chart.bottom);
    fill.close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF7ED0F0).withValues(alpha: 0.35),
            const Color(0xFF7ED0F0).withValues(alpha: 0.02),
          ],
        ).createShader(chart),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF3AA0D8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final dotColors = [
      const Color(0xFFF5C542),
      const Color(0xFF2EC4A0),
      const Color(0xFF5B9DEF),
      const Color(0xFFF5C542),
      const Color(0xFF2EC4A0),
      const Color(0xFF5B9DEF),
      const Color(0xFF2EC4A0),
    ];
    for (var i = 0; i < values.length; i++) {
      final x = chart.left + dx * i;
      final y = chart.bottom - values[i] * chart.height;
      canvas.drawCircle(Offset(x, y), 6.5, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(x, y), 4.6, Paint()..color = dotColors[i]);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(color: Color(0xFF8AA0B5), fontSize: 10, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, size.height - 14));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SparkleSmiley extends StatelessWidget {
  const SparkleSmiley({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CustomPaint(painter: _SmileyPainter(), child: const SizedBox.expand()),
    );
  }
}

class _SmileyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, 58);
    canvas.drawCircle(c, 36, Paint()..color = const Color(0xFF2EC4A0));
    canvas.drawCircle(c.translate(-11, -8), 4.2, Paint()..color = Colors.white);
    canvas.drawCircle(c.translate(11, -8), 4.2, Paint()..color = Colors.white);
    final smile = Path()
      ..addArc(Rect.fromCircle(center: c.translate(0, 4), radius: 16), 0.2, math.pi - 0.4);
    canvas.drawPath(
      smile,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round,
    );

    final spark = Paint()..color = const Color(0xFF7ED9C2);
    _star(canvas, Offset(c.dx - 58, 28), 7, spark);
    _star(canvas, Offset(c.dx + 56, 34), 6, spark);
    _star(canvas, Offset(c.dx - 40, 88), 5, spark);
    _star(canvas, Offset(c.dx + 42, 86), 5, spark);
    _star(canvas, Offset(c.dx + 8, 12), 4, spark);
  }

  void _star(Canvas canvas, Offset c, double r, Paint paint) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      final p = Offset(c.dx + math.cos(a) * r, c.dy + math.sin(a) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawCircle(c, r * 0.55, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CaregiverAvatar extends StatelessWidget {
  const CaregiverAvatar({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFF3D2C1), Color(0xFFE8B89A)],
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(painter: _PortraitPainter()),
      ),
    );
  }
}

class _PortraitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFF7D7C4));
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.42), width: size.width * 0.62, height: size.height * 0.58),
      Paint()..color = const Color(0xFFE8B496),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.22), width: size.width * 0.78, height: size.height * 0.5),
      Paint()..color = const Color(0xFF3A2A24),
    );
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.42), 3, Paint()..color = const Color(0xFF3A2A24));
    canvas.drawCircle(Offset(size.width * 0.62, size.height * 0.42), 3, Paint()..color = const Color(0xFF3A2A24));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Renders either an uploaded user photo or one of the authentic
/// illustrated scene presets from the Module 4 design.
class MemoryIllustration extends StatelessWidget {
  final String? illustrationKey;
  final String? localImagePath;
  final String? photoBase64;
  final String? photoUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const MemoryIllustration({
    super.key,
    this.illustrationKey,
    this.localImagePath,
    this.photoBase64,
    this.photoUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    // 1. Local Image Path if exists
    if (localImagePath != null && localImagePath!.isNotEmpty) {
      if (kIsWeb) {
        child = Image.network(
          localImagePath!,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackIllustration(),
        );
      } else {
        final file = File(localImagePath!);
        if (file.existsSync()) {
          child = Image.file(
            file,
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) =>
                _buildFallbackIllustration(),
          );
        } else {
          child = _buildFallbackIllustration();
        }
      }
    }
    // 2. Base64 Photo
    else if (photoBase64 != null && photoBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(photoBase64!);
        child = Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallbackIllustration(),
        );
      } catch (_) {
        child = _buildFallbackIllustration();
      }
    }
    // 3. Network URL
    else if (photoUrl != null && photoUrl!.isNotEmpty) {
      child = Image.network(
        photoUrl!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackIllustration(),
      );
    }
    // 4. Illustrated scene preset from the designs
    else {
      child = _buildFallbackIllustration();
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox(width: width, height: height, child: child),
      );
    }

    return SizedBox(width: width, height: height, child: child);
  }

  Widget _buildFallbackIllustration() {
    return CustomPaint(
      size: Size(width ?? double.infinity, height ?? double.infinity),
      painter: _SceneCustomPainter(illustrationKey ?? 'eid_house'),
    );
  }
}

class _SceneCustomPainter extends CustomPainter {
  final String key;
  const _SceneCustomPainter(this.key);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final rect = Offset.zero & size;

    switch (key) {
      case 'school_day':
      case 'first_day_school':
        _paintSchoolDay(canvas, rect);
        break;
      case 'lahore_fort':
        _paintLahoreFort(canvas, rect);
        break;
      case 'murree_picnic':
        _paintMurreePicnic(canvas, rect);
        break;
      case 'graduation':
        _paintGraduation(canvas, rect);
        break;
      case 'wedding':
        _paintWedding(canvas, rect);
        break;
      case 'eid_house':
      default:
        _paintEidHouse(canvas, rect);
        break;
    }
  }

  // 1. Eid at Nani's / Eid 1998 (House at night with crescent moon and stars)
  void _paintEidHouse(Canvas canvas, Rect rect) {
    final w = rect.width;
    final h = rect.height;

    // Dark Night Sky Gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0D2847), Color(0xFF133E6E), Color(0xFF1F5896)],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // Crescent Moon
    final moonCenter = Offset(w * 0.78, h * 0.28);
    final moonPaint = Paint()..color = const Color(0xFFFDE68A);
    final moonPath = Path()
      ..addArc(
        Rect.fromCircle(center: moonCenter, radius: h * 0.12),
        -1.5,
        3.14,
      )
      ..arcTo(
        Rect.fromCircle(
          center: Offset(moonCenter.dx + h * 0.05, moonCenter.dy),
          radius: h * 0.11,
        ),
        1.6,
        -3.14,
        false,
      );
    canvas.drawPath(moonPath, moonPaint);

    // Stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    final stars = [
      Offset(w * 0.18, h * 0.2),
      Offset(w * 0.35, h * 0.16),
      Offset(w * 0.52, h * 0.25),
      Offset(w * 0.72, h * 0.14),
      Offset(w * 0.88, h * 0.32),
    ];
    for (final s in stars) {
      canvas.drawCircle(s, 1.8, starPaint);
    }

    // Green Grass ground
    final grassPaint = Paint()..color = const Color(0xFF2E7D48);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.28), grassPaint);

    // House Base (Light Cream/White)
    final houseW = w * 0.36;
    final houseH = h * 0.32;
    final houseLeft = (w - houseW) / 2;
    final houseTop = h * 0.44;
    final housePaint = Paint()..color = const Color(0xFFFFFBEB);
    canvas.drawRect(
      Rect.fromLTWH(houseLeft, houseTop, houseW, houseH),
      housePaint,
    );

    // Green Roof
    final roofPaint = Paint()..color = const Color(0xFF48BB78);
    final roofPath = Path()
      ..moveTo(houseLeft - w * 0.04, houseTop)
      ..lineTo(w * 0.5, houseTop - h * 0.14)
      ..lineTo(houseLeft + houseW + w * 0.04, houseTop)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Blue Door
    final doorPaint = Paint()..color = const Color(0xFF0F4C81);
    final doorW = houseW * 0.3;
    final doorH = houseH * 0.65;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          houseLeft + (houseW - doorW) / 2,
          houseTop + houseH - doorH,
          doorW,
          doorH,
        ),
        const Radius.circular(3),
      ),
      doorPaint,
    );

    // Yellow Lit Windows
    final windowPaint = Paint()..color = const Color(0xFFFBBF24);
    final winSize = houseW * 0.2;
    canvas.drawRect(
      Rect.fromLTWH(
        houseLeft + houseW * 0.12,
        houseTop + houseH * 0.22,
        winSize,
        winSize,
      ),
      windowPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        houseLeft + houseW * 0.68,
        houseTop + houseH * 0.22,
        winSize,
        winSize,
      ),
      windowPaint,
    );
  }

  // 2. Lahore Fort (Historical Sandstone Mughal Fort)
  void _paintLahoreFort(Canvas canvas, Rect rect) {
    final w = rect.width;
    final h = rect.height;

    // Morning Blue Sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF90CDF4), Color(0xFFBEE3F8), Color(0xFFE2E8F0)],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // Sun & Orb in sky
    canvas.drawCircle(
      Offset(w * 0.3, h * 0.24),
      h * 0.09,
      Paint()..color = const Color(0xFFFDE68A),
    );
    canvas.drawCircle(
      Offset(w * 0.52, h * 0.22),
      h * 0.06,
      Paint()..color = const Color(0xFF4299E1),
    );

    // Green lawn
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.74, w, h * 0.26),
      Paint()..color = const Color(0xFF38A169),
    );

    // Sandstone Fort Structure
    final fortPaint = Paint()..color = const Color(0xFFD69E2E);
    final fortLeft = w * 0.15;
    final fortW = w * 0.7;
    final fortTop = h * 0.42;
    final fortH = h * 0.34;
    canvas.drawRect(Rect.fromLTWH(fortLeft, fortTop, fortW, fortH), fortPaint);

    // Fort Battlements / Towers on Top
    final towerPaint = Paint()..color = const Color(0xFFB7791F);
    for (int i = 0; i < 4; i++) {
      final tX = fortLeft + (i * (fortW / 3.8));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(tX, fortTop - h * 0.06, fortW * 0.16, h * 0.08),
          const Radius.circular(2),
        ),
        towerPaint,
      );
    }

    // Three Mughal Arches
    final archPaint = Paint()..color = const Color(0xFF744210);
    final archW = fortW * 0.18;
    final archH = fortH * 0.65;
    for (int i = 0; i < 3; i++) {
      final aX = fortLeft + fortW * 0.14 + (i * (archW + fortW * 0.12));
      final archPath = Path()
        ..moveTo(aX, fortTop + fortH)
        ..lineTo(aX, fortTop + fortH - archH * 0.6)
        ..arcTo(
          Rect.fromLTWH(aX, fortTop + fortH - archH, archW, archH * 0.8),
          3.14,
          3.14,
          false,
        )
        ..lineTo(aX + archW, fortTop + fortH)
        ..close();
      canvas.drawPath(archPath, archPaint);
    }
  }

  // 3. Family picnic in Murree (Rolling green hills & sunset cottage)
  void _paintMurreePicnic(Canvas canvas, Rect rect) {
    final w = rect.width;
    final h = rect.height;

    // Warm Sunset Sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFBD38D), Color(0xFFFED7E2), Color(0xFFE2E8F0)],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // Warm Sun
    canvas.drawCircle(
      Offset(w * 0.28, h * 0.35),
      h * 0.12,
      Paint()..color = const Color(0xFFF6AD55),
    );

    // Distant Hill
    final hill1 = Path()
      ..moveTo(0, h * 0.65)
      ..quadraticBezierTo(w * 0.4, h * 0.48, w, h * 0.6)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill1, Paint()..color = const Color(0xFF48BB78));

    // Foreground Hill
    final hill2 = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.6, h * 0.58, w, h * 0.7)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hill2, Paint()..color = const Color(0xFF2F855A));

    // Small White Cottage in hills
    final cLeft = w * 0.42;
    final cTop = h * 0.56;
    final cW = w * 0.2;
    final cH = h * 0.16;
    canvas.drawRect(
      Rect.fromLTWH(cLeft, cTop, cW, cH),
      Paint()..color = Colors.white,
    );
    final cRoof = Path()
      ..moveTo(cLeft - 4, cTop)
      ..lineTo(cLeft + cW / 2, cTop - h * 0.08)
      ..lineTo(cLeft + cW + 4, cTop)
      ..close();
    canvas.drawPath(cRoof, Paint()..color = const Color(0xFFE53E3E));
    canvas.drawRect(
      Rect.fromLTWH(cLeft + cW * 0.35, cTop + cH * 0.4, cW * 0.3, cH * 0.6),
      Paint()..color = const Color(0xFF2B6CB0),
    );
  }

  // 4. Graduation (University Hall with Mortarboard)
  void _paintGraduation(Canvas canvas, Rect rect) {
    final w = rect.width;
    final h = rect.height;

    // Academic Light Blue Sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFBEE3F8), Color(0xFFEBF8FF), Colors.white],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // Green Campus Ground
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.76, w, h * 0.24),
      Paint()..color = const Color(0xFF276749),
    );

    // University Hall Pediment / Roof
    final bLeft = w * 0.16;
    final bW = w * 0.68;
    final bTop = h * 0.44;
    final roofPath = Path()
      ..moveTo(bLeft - w * 0.04, bTop)
      ..lineTo(w * 0.5, bTop - h * 0.14)
      ..lineTo(bLeft + bW + w * 0.04, bTop)
      ..close();
    canvas.drawPath(roofPath, Paint()..color = const Color(0xFF2B6CB0));

    // Hall Base & Pillars
    canvas.drawRect(
      Rect.fromLTWH(bLeft, bTop, bW, h * 0.34),
      Paint()..color = const Color(0xFFEDF2F7),
    );
    final pillarPaint = Paint()..color = const Color(0xFFCBD5E0);
    for (int i = 0; i < 4; i++) {
      final pX = bLeft + bW * 0.1 + (i * (bW * 0.24));
      canvas.drawRect(
        Rect.fromLTWH(pX, bTop, bW * 0.08, h * 0.34),
        pillarPaint,
      );
    }

    // Black Graduation Cap (Mortarboard) in Foreground
    final capCenterX = w * 0.5;
    final capCenterY = h * 0.74;
    final capPaint = Paint()..color = const Color(0xFF1A202C);
    final capDiamond = Path()
      ..moveTo(capCenterX, capCenterY - h * 0.08)
      ..lineTo(capCenterX + w * 0.14, capCenterY - h * 0.02)
      ..lineTo(capCenterX, capCenterY + h * 0.04)
      ..lineTo(capCenterX - w * 0.14, capCenterY - h * 0.02)
      ..close();
    canvas.drawPath(capDiamond, capPaint);
    // Tassel
    canvas.drawCircle(
      Offset(capCenterX, capCenterY - h * 0.02),
      2.5,
      Paint()..color = const Color(0xFFD69E2E),
    );
    canvas.drawLine(
      Offset(capCenterX, capCenterY - h * 0.02),
      Offset(capCenterX + w * 0.1, capCenterY + h * 0.03),
      Paint()
        ..color = const Color(0xFFD69E2E)
        ..strokeWidth = 2,
    );
  }

  // 5. Wedding Day (Floral Arch with Bride & Groom Silhouette)
  void _paintWedding(Canvas canvas, Rect rect) {
    final w = rect.width;
    final h = rect.height;

    // Soft Pastel Morning Sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFEBF8FF), Color(0xFFFED7E2), Color(0xFFE2E8F0)],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // Green Lawn
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.72, w, h * 0.28),
      Paint()..color = const Color(0xFF38A169),
    );

    // Floral Arch Curve
    final archCenter = Offset(w * 0.5, h * 0.72);
    final archRadius = h * 0.36;
    final archPaint = Paint()
      ..color = const Color(0xFF276749)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawArc(
      Rect.fromCircle(center: archCenter, radius: archRadius),
      3.14,
      3.14,
      false,
      archPaint,
    );

    // Flowers on the Arch
    final flowerColors = [
      const Color(0xFFED64A6),
      Colors.white,
      const Color(0xFFFBBF24),
      const Color(0xFFF687B3),
      Colors.white,
      const Color(0xFFED64A6),
      const Color(0xFFFBBF24),
    ];
    for (int i = 0; i < flowerColors.length; i++) {
      final angle = 3.14 + (i * (3.14 / (flowerColors.length - 1)));
      final fX =
          archCenter.dx +
          (archRadius * 1.0) *
              (angle > 3.14 ? -1 : 1) *
              (0.8 - (i * 0.26)).abs();
      final fY =
          archCenter.dy - (archRadius * 0.95) * (1 - (0.8 - (i * 0.26)).abs());
      canvas.drawCircle(Offset(fX, fY), 5.5, Paint()..color = flowerColors[i]);
    }

    // Bride and Groom Stylized Avatars
    final groomPaint = Paint()..color = const Color(0xFF2B6CB0);
    final bridePaint = Paint()..color = Colors.white;

    // Groom
    canvas.drawCircle(
      Offset(w * 0.44, h * 0.64),
      h * 0.04,
      Paint()..color = const Color(0xFFECC94B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.40, h * 0.69, w * 0.08, h * 0.14),
        const Radius.circular(8),
      ),
      groomPaint,
    );

    // Bride
    canvas.drawCircle(
      Offset(w * 0.56, h * 0.64),
      h * 0.04,
      Paint()..color = const Color(0xFFECC94B),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.52, h * 0.69, w * 0.08, h * 0.14),
        const Radius.circular(8),
      ),
      bridePaint,
    );
  }

  // 6. First day of school (Karachi, sunrise over schoolhouse and trees)
  void _paintSchoolDay(Canvas canvas, Rect rect) {
    final w = rect.width;
    final h = rect.height;

    // Morning Sunrise Gradient Sky (Peach / Warm Sun glow to soft sky blue)
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFED7AA), Color(0xFFFEF08A), Color(0xFFBAE6FD)],
      ).createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // Glowing Morning Sun on top-right
    final sunCenter = Offset(w * 0.76, h * 0.30);
    final sunHaloPaint = Paint()
      ..color = const Color(0xFFFEF9C3).withValues(alpha: 0.5);
    canvas.drawCircle(sunCenter, h * 0.18, sunHaloPaint);
    final sunPaint = Paint()..color = const Color(0xFFFDE047);
    canvas.drawCircle(sunCenter, h * 0.12, sunPaint);

    // Distant soft hill
    final hillPath1 = Path()
      ..moveTo(0, h * 0.70)
      ..quadraticBezierTo(w * 0.35, h * 0.55, w, h * 0.65)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hillPath1, Paint()..color = const Color(0xFF48BB78));

    // Foreground rolling lawn
    final hillPath2 = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.65, h * 0.65, w, h * 0.74)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(hillPath2, Paint()..color = const Color(0xFF276749));

    // Schoolhouse Building
    final schoolW = w * 0.34;
    final schoolH = h * 0.32;
    final schoolLeft = (w - schoolW) / 2;
    final schoolTop = h * 0.44;

    // School base wall (Cream/White)
    final wallPaint = Paint()..color = const Color(0xFFFFFBEB);
    canvas.drawRect(
      Rect.fromLTWH(schoolLeft, schoolTop, schoolW, schoolH),
      wallPaint,
    );

    // Dark Blue Gable Roof
    final roofPaint = Paint()..color = const Color(0xFF1E3A8A);
    final roofPath = Path()
      ..moveTo(schoolLeft - w * 0.04, schoolTop)
      ..lineTo(w * 0.5, schoolTop - h * 0.14)
      ..lineTo(schoolLeft + schoolW + w * 0.04, schoolTop)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Blue Door
    final doorPaint = Paint()..color = const Color(0xFF2563EB);
    final doorW = schoolW * 0.28;
    final doorH = schoolH * 0.65;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          schoolLeft + (schoolW - doorW) / 2,
          schoolTop + schoolH - doorH,
          doorW,
          doorH,
        ),
        const Radius.circular(3),
      ),
      doorPaint,
    );

    // Left and Right windows (Soft lit yellow)
    final winPaint = Paint()..color = const Color(0xFFFDE68A);
    final winSize = schoolW * 0.18;
    canvas.drawRect(
      Rect.fromLTWH(
        schoolLeft + schoolW * 0.1,
        schoolTop + schoolH * 0.25,
        winSize,
        winSize,
      ),
      winPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        schoolLeft + schoolW * 0.72,
        schoolTop + schoolH * 0.25,
        winSize,
        winSize,
      ),
      winPaint,
    );

    // Flanking Trees/Bushes
    final treePaint = Paint()..color = const Color(0xFF1F6B38);
    canvas.drawCircle(
      Offset(schoolLeft - w * 0.05, schoolTop + schoolH * 0.7),
      h * 0.09,
      treePaint,
    );
    canvas.drawCircle(
      Offset(schoolLeft + schoolW + w * 0.05, schoolTop + schoolH * 0.7),
      h * 0.09,
      treePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SceneCustomPainter oldDelegate) =>
      oldDelegate.key != key;
}

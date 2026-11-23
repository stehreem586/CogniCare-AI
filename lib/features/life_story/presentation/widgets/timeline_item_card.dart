import 'package:flutter/material.dart';
import '../../data/models/memory_model.dart';
import 'memory_illustration.dart';

/// Reusable timeline item widget rendering a continuous vertical timeline
/// connector, milestone node, age/year badge, and interactive memory card.
class TimelineItemCard extends StatelessWidget {
  final MemoryModel memory;
  final bool isFirst;
  final bool isLast;
  final int patientBirthYear;
  final VoidCallback? onTap;

  const TimelineItemCard({
    super.key,
    required this.memory,
    this.isFirst = false,
    this.isLast = false,
    this.patientBirthYear = 1983,
    this.onTap,
  });

  Color _getEraColor(String era) {
    switch (era.toLowerCase()) {
      case 'childhood':
        return const Color(0xFF2EAA55);
      case 'adulthood':
        return const Color(0xFF0066BD);
      case 'recent':
        return const Color(0xFFE56A54);
      default:
        return const Color(0xFF2EAA55);
    }
  }

  Gradient _getEraGradient(String era) {
    switch (era.toLowerCase()) {
      case 'childhood':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF48BB78), Color(0xFF2EAA55)],
        );
      case 'adulthood':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E88E5), Color(0xFF0066BD)],
        );
      case 'recent':
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF9800), Color(0xFFE65100)],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF48BB78), Color(0xFF2EAA55)],
        );
    }
  }

  int _calculateAge(DateTime date) {
    final age = date.year - patientBirthYear;
    return age > 0 ? age : 0;
  }

  String _formatSubtitle(MemoryModel memory) {
    final hasPlace = memory.place.isNotEmpty;
    final hasPeople = memory.taggedPeople.isNotEmpty;

    if (hasPlace && hasPeople) {
      return '${memory.place} • ${memory.taggedPeople.length} people';
    } else if (hasPlace) {
      return memory.place;
    } else if (hasPeople) {
      return '${memory.taggedPeople.length} people';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final eraColor = _getEraColor(memory.era);
    final eraGradient = _getEraGradient(memory.era);
    final age = _calculateAge(memory.date);
    final subtitle = _formatSubtitle(memory);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Left Vertical Timeline Connector & Milestone Node
          SizedBox(
            width: 52,
            child: CustomPaint(
              painter: _TimelineConnectorPainter(
                isFirst: isFirst,
                isLast: isLast,
                nodeGradient: eraGradient,
                lineColor: eraColor,
              ),
            ),
          ),

          // 2. Right Event Details & Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Year & Age Badge
                  Text(
                    '${memory.date.year} • Age $age',
                    style: TextStyle(
                      color: eraColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Memory Card Container
                  GestureDetector(
                    onTap: onTap,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 136,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Scenic Illustration / User Photo
                            MemoryIllustration(
                              illustrationKey: memory.illustrationKey,
                              localImagePath: memory.localImagePath,
                              photoBase64: memory.photoBase64,
                              photoUrl: memory.photoUrl,
                              fit: BoxFit.cover,
                            ),

                            // Bottom Scrim Gradient for text contrast
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Color(0x20000000),
                                    Color(0xCC000000),
                                  ],
                                  stops: [0.3, 0.65, 1.0],
                                ),
                              ),
                            ),

                            // Bottom Content: Title & Subtitle
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 14,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    memory.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  if (subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.9,
                                        ),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for seamless vertical connector lines and smooth milestone nodes
class _TimelineConnectorPainter extends CustomPainter {
  final bool isFirst;
  final bool isLast;
  final Gradient nodeGradient;
  final Color lineColor;

  const _TimelineConnectorPainter({
    required this.isFirst,
    required this.isLast,
    required this.nodeGradient,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const nodeRadius = 11.5;
    const nodeCenterY = 9.5; // Aligns with the baseline of "1989 • Age 6"
    final centerX = size.width * 0.58;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Line from top of item to node (for non-first items)
    if (!isFirst) {
      canvas.drawLine(
        Offset(centerX, 0),
        Offset(centerX, nodeCenterY - nodeRadius),
        linePaint,
      );
    }

    // Line from node to bottom of item (for non-last items)
    if (!isLast) {
      canvas.drawLine(
        Offset(centerX, nodeCenterY + nodeRadius),
        Offset(centerX, size.height),
        linePaint,
      );
    }

    // Node Circle with Gradient
    final nodeCenter = Offset(centerX, nodeCenterY);
    final nodeRect = Rect.fromCircle(center: nodeCenter, radius: nodeRadius);
    final nodePaint = Paint()
      ..shader = nodeGradient.createShader(nodeRect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(nodeCenter, nodeRadius, nodePaint);
  }

  @override
  bool shouldRepaint(covariant _TimelineConnectorPainter oldDelegate) {
    return oldDelegate.isFirst != isFirst ||
        oldDelegate.isLast != isLast ||
        oldDelegate.lineColor != lineColor;
  }
}

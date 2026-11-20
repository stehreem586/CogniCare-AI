import 'package:flutter/material.dart';
import '../../data/models/memory_model.dart';
import 'memory_illustration.dart';

class MemoryCard extends StatelessWidget {
  final MemoryModel memory;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final bool showDate;

  const MemoryCard({
    super.key,
    required this.memory,
    this.onTap,
    this.width,
    this.height,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Illustration / Photo
                MemoryIllustration(
                  illustrationKey: memory.illustrationKey,
                  localImagePath: memory.localImagePath,
                  photoBase64: memory.photoBase64,
                  photoUrl: memory.photoUrl,
                  fit: BoxFit.cover,
                ),

                // Dark Scrim Gradient for text legibility
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x22000000),
                        Color(0xCC000000),
                      ],
                      stops: [0.3, 0.65, 1.0],
                    ),
                  ),
                ),

                // Bottom Content
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (showDate) ...[
                        Text(
                          '${memory.date.year}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        memory.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

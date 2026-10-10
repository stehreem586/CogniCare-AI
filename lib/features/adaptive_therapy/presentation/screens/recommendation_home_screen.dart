import 'package:flutter/material.dart';
import '../../data/mock_therapy_data.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';
import '../widgets/therapy_illustrations.dart';

class RecommendationHomeScreen extends StatelessWidget {
  const RecommendationHomeScreen({
    super.key,
    required this.onOpenTypes,
    required this.onStartRecommended,
    required this.onOpenWellness,
    required this.onOpenCognitive,
    required this.onOpenMemory,
  });

  final VoidCallback onOpenTypes;
  final VoidCallback onStartRecommended;
  final VoidCallback onOpenWellness;
  final VoidCallback onOpenCognitive;
  final VoidCallback onOpenMemory;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              const TherapyBrandMark(),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'CogniCare ',
                            style: TextStyle(
                              color: TherapyColors.navy,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(
                            text: 'AI',
                            style: TextStyle(
                              color: TherapyColors.tealDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Smarter Support. Brighter Days.',
                      style: TextStyle(
                        color: TherapyColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const TherapyBellButton(),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Good Morning, ${TherapyMocks.patientFirstName}!',
            style: TextStyle(
              color: TherapyColors.navy,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Let's do something good for your mind today.",
            style: TextStyle(color: TherapyColors.body, fontSize: 14.5, height: 1.4),
          ),
          const SizedBox(height: 18),
          TherapyCard(
            color: const Color(0xFFE7F7F1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded, color: TherapyColors.tealDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text.rich(
                        TextSpan(
                          style: TextStyle(color: TherapyColors.body, fontSize: 13.5, height: 1.4),
                          children: [
                            TextSpan(text: 'Based on your current mood '),
                            TextSpan(
                              text: 'we recommend a Relaxation Exercise',
                              style: TextStyle(
                                color: TherapyColors.navy,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: ' to help you feel calmer.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: onStartRecommended,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TherapyColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Start Now', style: TextStyle(fontWeight: FontWeight.w700)),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            "Today's Recommendation",
            style: TextStyle(
              color: TherapyColors.navy,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          TherapyCard(
            onTap: onStartRecommended,
            child: Row(
              children: [
                const TherapyIconBubble(kind: TherapyIconKind.leaf, size: 52),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Breathing Exercise',
                        style: TextStyle(
                          color: TherapyColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Calm  •  3 minutes',
                        style: TextStyle(
                          color: TherapyColors.tealDark,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'A simple breathing exercise to reduce stress and improve focus.',
                        style: TextStyle(color: TherapyColors.body, fontSize: 12.5, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _QuickAction(
                color: const Color(0xFFE7F7F1),
                iconColor: TherapyColors.tealDark,
                icon: Icons.sports_esports_rounded,
                label: 'Mind Games\n& Activities',
                onTap: onOpenCognitive,
              ),
              _QuickAction(
                color: TherapyColors.cardPink,
                iconColor: const Color(0xFFE56B9A),
                icon: Icons.psychology_alt_rounded,
                label: 'Memory\nExercises',
                onTap: onOpenMemory,
              ),
              _QuickAction(
                color: TherapyColors.cardPeach,
                iconColor: const Color(0xFFF0A100),
                icon: Icons.lightbulb_rounded,
                label: 'Wellness\nTips',
                onTap: onOpenWellness,
              ),
              _QuickAction(
                color: TherapyColors.cardPurple,
                iconColor: const Color(0xFF9B6BDB),
                icon: Icons.apps_rounded,
                label: 'View All',
                onTap: onOpenTypes,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final Color iconColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TherapyColors.navy,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

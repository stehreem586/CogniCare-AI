import 'package:flutter/material.dart';
import '../../data/mock_therapy_data.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';
import '../widgets/therapy_illustrations.dart';

class ActivityCompleteScreen extends StatelessWidget {
  const ActivityCompleteScreen({
    super.key,
    required this.onViewNext,
    required this.onBackHome,
  });

  final VoidCallback onViewNext;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return TherapyPage(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const SparkleSmiley(),
              const SizedBox(height: 8),
              const Text(
                'Great Job, ${TherapyMocks.patientFirstName}!',
                style: TextStyle(
                  color: TherapyColors.navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'You completed the relaxation exercise.',
                style: TextStyle(color: TherapyColors.body, fontSize: 14.5),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your Current Emotion',
                  style: TextStyle(
                    color: TherapyColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TherapyCard(
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE7F7F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.sentiment_satisfied_alt_rounded, color: TherapyColors.tealDark, size: 30),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          TherapyMocks.emotion,
                          style: TextStyle(
                            color: TherapyColors.navy,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Confidence: ${TherapyMocks.confidence}%',
                          style: TextStyle(color: TherapyColors.muted, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recommended for You',
                  style: TextStyle(
                    color: TherapyColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TherapyCard(
                color: const Color(0xFFF6EEFC),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.self_improvement_rounded, color: Color(0xFF9B6BDB)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Continue with a short mindfulness activity to maintain your calm mood.',
                        style: TextStyle(color: TherapyColors.body, fontSize: 13.5, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TherapyPrimaryButton(label: 'View Next Activity', onPressed: onViewNext),
              const SizedBox(height: 8),
              TextButton(
                onPressed: onBackHome,
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: TherapyColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

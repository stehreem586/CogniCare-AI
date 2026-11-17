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
    this.result,
  });

  final VoidCallback onViewNext;
  final VoidCallback onBackHome;
  final TherapyActivityResult? result;

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
              Text(
                result == null
                    ? 'You completed the relaxation exercise.'
                    : 'You completed ${result!.activityTitle}.',
                style: TextStyle(color: TherapyColors.body, fontSize: 14.5),
              ),
              if (result != null) ...[
                const SizedBox(height: 18),
                TherapyCard(
                  color: const Color(0xFFE7F7F1),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.insights_rounded,
                        color: TherapyColors.tealDark,
                        size: 34,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Session score',
                              style: TextStyle(
                                color: TherapyColors.body,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${result!.percentage}%  ·  ${result!.correctAnswers} of ${result!.totalQuestions} correct',
                              style: const TextStyle(
                                color: TherapyColors.navy,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
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

import 'package:flutter/material.dart';
import '../../data/mock_therapy_data.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';

class ActivityDetailScreen extends StatelessWidget {
  const ActivityDetailScreen({
    super.key,
    this.activity = MockTherapyCatalog.breathing,
    required this.onStart,
  });

  final TherapyActivity activity;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return TherapyPage(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              const TherapyBackHeader(title: 'Activity Details'),
              const SizedBox(height: 12),
              TherapyIconBubble(kind: activity.iconKind, size: 86),
              const SizedBox(height: 16),
              Text(
                activity.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TherapyColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.spa_rounded, size: 16, color: TherapyColors.tealDark),
                  const SizedBox(width: 6),
                  Text(
                    '${activity.category}   •   ${activity.durationLabel}',
                    style: const TextStyle(
                      color: TherapyColors.tealDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Description',
                  style: TextStyle(
                    color: TherapyColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  activity.description,
                  style: const TextStyle(color: TherapyColors.body, fontSize: 14.5, height: 1.45),
                ),
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Benefits',
                  style: TextStyle(
                    color: TherapyColors.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              for (final benefit in activity.benefits)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: TherapyColors.tealDark, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        benefit,
                        style: const TextStyle(color: TherapyColors.body, fontSize: 14.5),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              TherapyPrimaryButton(label: 'Start Activity', onPressed: onStart),
              const SizedBox(height: 12),
              TherapyOutlineButton(
                label: 'Save for Later',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved for later (frontend only)')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

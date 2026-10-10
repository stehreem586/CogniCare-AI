import 'package:flutter/material.dart';
import '../../data/mock_therapy_data.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_bottom_nav.dart';
import '../widgets/therapy_common.dart';
import 'progress_tracking_screen.dart';
import 'recommendation_home_screen.dart';
import 'wellness_tips_screen.dart';

class PatientTherapyShell extends StatefulWidget {
  const PatientTherapyShell({super.key});

  @override
  State<PatientTherapyShell> createState() => _PatientTherapyShellState();
}

class _PatientTherapyShellState extends State<PatientTherapyShell> {
  int _index = 0;

  void _go(String route) {
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      RecommendationHomeScreen(
        onOpenTypes: () => _go(TherapyRouteNames.types),
        onStartRecommended: () => _go(TherapyRouteNames.activityDetail),
        onOpenWellness: () => setState(() => _index = 1),
        onOpenCognitive: () => _go(TherapyRouteNames.cognitiveGame),
        onOpenMemory: () => _go(TherapyRouteNames.memoryExercise),
      ),
      const WellnessTipsScreen(),
      const ProgressTrackingScreen(),
      _MoreTab(
        onCaregiver: () => _go(TherapyRouteNames.caregiver),
        onTypes: () => _go(TherapyRouteNames.types),
      ),
    ];

    return TherapyPage(
      bottomNavigationBar: TherapyBottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
      child: IndexedStack(index: _index, children: pages),
    );
  }
}

class _MoreTab extends StatelessWidget {
  const _MoreTab({required this.onCaregiver, required this.onTypes});

  final VoidCallback onCaregiver;
  final VoidCallback onTypes;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          const Text(
            'More',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TherapyColors.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          TherapyCard(
            onTap: onTypes,
            child: const Row(
              children: [
                TherapyIconBubble(kind: TherapyIconKind.leaf),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All therapy types',
                    style: TextStyle(
                      color: TherapyColors.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: TherapyColors.muted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TherapyCard(
            onTap: onCaregiver,
            child: const Row(
              children: [
                TherapyIconBubble(kind: TherapyIconKind.routine),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Caregiver view (Module 3)',
                    style: TextStyle(
                      color: TherapyColors.navy,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: TherapyColors.muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

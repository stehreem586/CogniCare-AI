import 'package:flutter/material.dart';

import '../../data/mock_therapy_data.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';
import 'progress_tracking_screen.dart';
import 'recommendation_home_screen.dart';
import 'recommendation_types_screen.dart';

class PatientTherapyShell extends StatefulWidget {
  const PatientTherapyShell({
    super.key,
    this.activities,
    this.typeItems,
    this.recommendedActivity,
    this.initialTab = TherapyModuleTab.home,
  });

  final List<TherapyActivity>? activities;
  final List<TherapyTypeItem>? typeItems;
  final TherapyActivity? recommendedActivity;
  final TherapyModuleTab initialTab;

  @override
  State<PatientTherapyShell> createState() => _PatientTherapyShellState();
}

class _PatientTherapyShellState extends State<PatientTherapyShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialTab.index;
  }

  void _go(String route) {
    Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final navigation = TherapyNavigationScope.maybeOf(context);
    final index = navigation?.currentIndex ?? _index;

    void selectTab(int tab) {
      if (navigation != null) {
        navigation.onTap(tab);
      } else {
        setState(() => _index = tab);
      }
    }

    final pages = [
      RecommendationHomeScreen(
        activities: widget.activities,
        recommendedActivity: widget.recommendedActivity,
        onOpenTypes: () => _go(TherapyRouteNames.types),
        onStartRecommended: () => _go(TherapyRouteNames.activityDetail),
        onOpenWellness: () => selectTab(1),
        onOpenCognitive: () => _go(TherapyRouteNames.cognitiveGame),
        onOpenMemory: () => _go(TherapyRouteNames.memoryExercise),
      ),
      RecommendationTypesScreen(
        items: widget.typeItems,
        onSelect: (item) => Navigator.of(context).pushNamed(
          item.routeName,
          arguments: item,
        ),
      ),
      const ProgressTrackingScreen(),
      _MoreTab(
        onTypes: () => _go(TherapyRouteNames.types),
        onWellness: () => _go(TherapyRouteNames.wellness),
      ),
    ];

    return TherapyPage(
      child: IndexedStack(index: index, children: pages),
    );
  }
}

class _MoreTab extends StatelessWidget {
  const _MoreTab({required this.onTypes, required this.onWellness});

  final VoidCallback onTypes;
  final VoidCallback onWellness;

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
            onTap: onWellness,
            child: const Row(
              children: [
                TherapyIconBubble(kind: TherapyIconKind.mindfulness),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Wellness tips',
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

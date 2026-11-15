import 'package:flutter/material.dart';

import '../../data/assessment_catalog.dart';
import '../../data/models/therapy_models.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';

class AssessmentActivitiesScreen extends StatelessWidget {
  const AssessmentActivitiesScreen({super.key, required this.selectedActivities, required this.onStart});

  final List<AssessmentActivityDefinition> selectedActivities;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text('Activities', style: TextStyle(color: TherapyColors.navy, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text('This assessment has three selected activities. The other activities remain available for future sessions.', style: TextStyle(color: TherapyColors.body, fontSize: 20, height: 1.4)),
          const SizedBox(height: 22),
          ...selectedActivities.asMap().entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TherapyCard(
                  color: const Color(0xFFE7F7F1),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 22, backgroundColor: TherapyColors.primary, child: Text('${entry.key + 1}', style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900))),
                      const SizedBox(width: 14),
                      Expanded(child: Text(entry.value.title, style: const TextStyle(color: TherapyColors.navy, fontSize: 20, fontWeight: FontWeight.w800))),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 12),
          SizedBox(
            height: 64,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(backgroundColor: TherapyColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Start selected activities', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 14),
          Text('Available activity types: ${AssessmentCatalog.activities.length}', textAlign: TextAlign.center, style: const TextStyle(color: TherapyColors.muted, fontSize: 17)),
        ],
      ),
    );
  }
}

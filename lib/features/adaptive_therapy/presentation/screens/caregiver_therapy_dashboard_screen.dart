import 'package:flutter/material.dart';
import '../../data/mock_therapy_data.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_bottom_nav.dart';
import '../widgets/therapy_common.dart';
import '../widgets/therapy_illustrations.dart';

class CaregiverTherapyDashboardScreen extends StatelessWidget {
  const CaregiverTherapyDashboardScreen({super.key, this.onViewDetails});

  final VoidCallback? onViewDetails;

  @override
  Widget build(BuildContext context) {
    return TherapyPage(
      bottomNavigationBar: TherapyBottomNav(
        caregiver: true,
        index: 0,
        onTap: (_) {},
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          children: [
            Row(
              children: [
                const CaregiverAvatar(size: 50),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        TherapyMocks.caregiverName,
                        style: TextStyle(
                          color: TherapyColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        TherapyMocks.caregiverRole,
                        style: TextStyle(color: TherapyColors.muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded, color: TherapyColors.muted),
                ),
                const TherapyBellButton(),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "${TherapyMocks.patientFirstName}'s Emotional Well-being",
                    style: TextStyle(
                      color: TherapyColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onViewDetails,
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      color: TherapyColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TherapyCard(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE7F7F1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.sentiment_satisfied_alt_rounded,
                      color: TherapyColors.tealDark,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    TherapyMocks.emotion,
                    style: TextStyle(
                      color: TherapyColors.navy,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Confidence: ${TherapyMocks.confidence}%',
                    style: TextStyle(color: TherapyColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Last updated: Today, 10:30 AM',
                    style: TextStyle(color: TherapyColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Recent Recommendations',
              style: TextStyle(
                color: TherapyColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            for (final rec in MockTherapyCatalog.caregiverRecs) ...[
              TherapyCard(
                child: Row(
                  children: [
                    TherapyIconBubble(kind: rec.iconKind, size: 48),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rec.title,
                            style: const TextStyle(
                              color: TherapyColors.navy,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${rec.status}  •  ${rec.time}',
                            style: TextStyle(
                              color: rec.status == 'Upcoming'
                                  ? TherapyColors.primaryDark
                                  : TherapyColors.muted,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

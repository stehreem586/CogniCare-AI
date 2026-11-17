import 'package:flutter/material.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';
import '../widgets/therapy_illustrations.dart';

class ProgressTrackingScreen extends StatelessWidget {
  const ProgressTrackingScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const dates = ['12', '13', '14', '15', '16', '17', '18'];
    const selected = 4;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (showBack)
            const TherapyBackHeader(title: 'Your Progress')
          else
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 12, 4, 12),
              child: Text(
                'Your Progress',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TherapyColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          TherapyCard(
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.chevron_left_rounded, color: TherapyColors.muted),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF6FD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'This Week',
                        style: TextStyle(
                          color: TherapyColors.primaryDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: TherapyColors.muted),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              days[i],
                              style: const TextStyle(
                                color: TherapyColors.muted,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 36,
                              height: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: i == selected ? TherapyColors.primary : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                dates[i],
                                style: TextStyle(
                                  color: i == selected ? Colors.white : TherapyColors.navy,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TherapyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Mood Trend',
                        style: TextStyle(
                          color: TherapyColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    _legend(const Color(0xFFF5C542), 'Happy'),
                    const SizedBox(width: 8),
                    _legend(const Color(0xFF2EC4A0), 'Calm'),
                    const SizedBox(width: 8),
                    _legend(const Color(0xFF5B9DEF), 'Sad'),
                  ],
                ),
                const SizedBox(height: 8),
                const MoodTrendChart(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TherapyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Activities Completed',
                        style: TextStyle(
                          color: TherapyColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '4 / 6',
                      style: TextStyle(
                        color: TherapyColors.primaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: const LinearProgressIndicator(
                    value: 0.67,
                    minHeight: 10,
                    backgroundColor: Color(0xFFEAF2F8),
                    color: TherapyColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '67%',
                    style: TextStyle(
                      color: TherapyColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: TherapyColors.muted, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/models/therapy_models.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';

class AssessmentHomeScreen extends StatelessWidget {
  const AssessmentHomeScreen({
    super.key,
    required this.onStart,
    required this.onReports,
    required this.reports,
  });

  final VoidCallback onStart;
  final VoidCallback onReports;
  final List<AssessmentSessionReport> reports;

  @override
  Widget build(BuildContext context) {
    final todayReport = reports.where((report) {
      final date = report.completedAt?.toLocal();
      final now = DateTime.now();
      return date != null &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).firstOrNull;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text(
            'Good to see you',
            style: TextStyle(
              color: TherapyColors.tealDark,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your cognitive dashboard',
            style: TextStyle(
              color: TherapyColors.navy,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '“Small steps build confidence, memory, and independence.”',
            style: TextStyle(
              color: TherapyColors.body,
              fontSize: 21,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          TherapyCard(
            color: const Color(0xFFEAF4FF),
            child: const _MemoryWellnessIllustration(),
          ),
          const SizedBox(height: 18),
          TherapyCard(
            color: const Color(0xFFE7F7F1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s progress',
                  style: TextStyle(
                    color: TherapyColors.navy,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  todayReport == null
                      ? 'No assessment completed today yet. Your score will appear here after you finish.'
                      : 'Today\'s assessment: ${todayReport.overallScore} / 100',
                  style: const TextStyle(
                    color: TherapyColors.body,
                    fontSize: 20,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                _LargeButton(label: 'Start assessment', onPressed: onStart),
              ],
            ),
          ),
          if (todayReport != null) ...[
            const SizedBox(height: 18),
            TherapyCard(
              child: Row(
                children: [
                  SizedBox(
                    width: 74,
                    height: 74,
                    child: CircularProgressIndicator(
                      value: todayReport.overallScore / 100,
                      strokeWidth: 9,
                      backgroundColor: const Color(0xFFEAF2F8),
                      color: TherapyColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Today\'s score\n${todayReport.overallScore} / 100',
                      style: const TextStyle(
                        color: TherapyColors.navy,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onReports,
            icon: const Icon(Icons.history_rounded, size: 28),
            label: const Text(
              'View assessment history',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(62),
              foregroundColor: TherapyColors.primary,
              side: const BorderSide(color: TherapyColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryWellnessIllustration extends StatelessWidget {
  const _MemoryWellnessIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 30,
            top: 18,
            child: _softBlob(const Color(0xFFBDEBFF), 76),
          ),
          Positioned(
            right: 28,
            bottom: 12,
            child: _softBlob(const Color(0xFFC7F3E2), 82),
          ),
          Positioned(
            left: 92,
            top: 22,
            child: _sparkle(const Color(0xFFF0C75E), 12),
          ),
          Positioned(
            right: 100,
            top: 14,
            child: _sparkle(const Color(0xFFF0C75E), 9),
          ),
          Positioned(
            left: 132,
            bottom: 18,
            child: _sparkle(const Color(0xFF65CDA3), 8),
          ),
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF24B98A), Color(0xFF1684C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(34),
              boxShadow: [
                BoxShadow(
                  color: TherapyColors.primary.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 12,
                  right: 14,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFFFFE08A),
                    size: 18,
                  ),
                ),
                Icon(
                  Icons.psychology_alt_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _softBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.72),
        shape: BoxShape.circle,
      ),
    );
  }

  static Widget _sparkle(Color color, double size) {
    return Icon(Icons.star_rounded, color: color, size: size);
  }
}

class _LargeButton extends StatelessWidget {
  const _LargeButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 64,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: TherapyColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
      ),
    ),
  );
}

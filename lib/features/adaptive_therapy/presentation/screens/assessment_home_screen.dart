import 'package:flutter/material.dart';

import '../../data/models/therapy_models.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';

class AssessmentHomeScreen extends StatelessWidget {
  const AssessmentHomeScreen({super.key, required this.onStart, required this.onReports, required this.reports});

  final VoidCallback onStart;
  final VoidCallback onReports;
  final List<AssessmentSessionReport> reports;

  @override
  Widget build(BuildContext context) {
    final todayReport = reports.where((report) {
      final date = report.completedAt?.toLocal();
      final now = DateTime.now();
      return date != null && date.year == now.year && date.month == now.month && date.day == now.day;
    }).firstOrNull;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          const Text('Good to see you', style: TextStyle(color: TherapyColors.tealDark, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('Your cognitive dashboard', style: TextStyle(color: TherapyColors.navy, fontSize: 32, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          const Text('“Small steps build confidence, memory, and independence.”', style: TextStyle(color: TherapyColors.body, fontSize: 21, height: 1.4, fontStyle: FontStyle.italic)),
          const SizedBox(height: 24),
          TherapyCard(
            color: const Color(0xFFEAF4FF),
            child: SizedBox(height: 130, child: CustomPaint(painter: _MemoryWellnessPainter())),
          ),
          const SizedBox(height: 18),
          TherapyCard(
            color: const Color(0xFFE7F7F1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Today\'s progress', style: TextStyle(color: TherapyColors.navy, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(todayReport == null ? 'No assessment completed today yet. Your score will appear here after you finish.' : 'Today\'s assessment: ${todayReport.overallScore} / 100', style: const TextStyle(color: TherapyColors.body, fontSize: 20, height: 1.35)),
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
                  SizedBox(width: 74, height: 74, child: CircularProgressIndicator(value: todayReport.overallScore / 100, strokeWidth: 9, backgroundColor: const Color(0xFFEAF2F8), color: TherapyColors.primary)),
                  const SizedBox(width: 16),
                  Expanded(child: Text('Today\'s score\n${todayReport.overallScore} / 100', style: const TextStyle(color: TherapyColors.navy, fontSize: 23, fontWeight: FontWeight.w900))),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onReports,
            icon: const Icon(Icons.history_rounded, size: 28),
            label: const Text('View assessment history', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(62), foregroundColor: TherapyColors.primary, side: const BorderSide(color: TherapyColors.primary, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          ),
        ],
      ),
    );
  }
}

class _MemoryWellnessPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = const Color(0xFFBDEBFF);
    final accent = Paint()..color = TherapyColors.tealDark..strokeWidth = 6..style = PaintingStyle.stroke;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawOval(Rect.fromCenter(center: center.translate(-30, 0), width: 92, height: 92), fill);
    canvas.drawOval(Rect.fromCenter(center: center.translate(30, 0), width: 92, height: 92), fill);
    canvas.drawPath(Path()..moveTo(center.dx - 8, center.dy - 30)..quadraticBezierTo(center.dx - 30, center.dy, center.dx - 8, center.dy + 30), accent);
    canvas.drawPath(Path()..moveTo(center.dx + 8, center.dy - 30)..quadraticBezierTo(center.dx + 30, center.dy, center.dx + 8, center.dy + 30), accent);
    for (final offset in [const Offset(-110, -35), const Offset(110, -25), const Offset(-95, 44), const Offset(100, 40)]) {
      canvas.drawCircle(center.translate(offset.dx, offset.dy), 7, Paint()..color = const Color(0xFFF0C75E));
    }
  }

  @override
  bool shouldRepaint(covariant _MemoryWellnessPainter oldDelegate) => false;
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
          style: ElevatedButton.styleFrom(backgroundColor: TherapyColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: Text(label, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
        ),
      );
}

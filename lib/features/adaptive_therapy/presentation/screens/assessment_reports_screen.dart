import 'package:flutter/material.dart';

import '../../data/models/therapy_models.dart';
import '../../data/repositories/adaptive_therapy_repository.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';

class AssessmentReportsScreen extends StatefulWidget {
  const AssessmentReportsScreen({
    super.key,
    required this.patientId,
    this.onBack,
  });

  final String patientId;
  final VoidCallback? onBack;

  @override
  State<AssessmentReportsScreen> createState() =>
      _AssessmentReportsScreenState();
}

class _AssessmentReportsScreenState extends State<AssessmentReportsScreen> {
  late Future<List<AssessmentSessionReport>> _reports;

  @override
  void initState() {
    super.initState();
    _reports = AdaptiveTherapyRepository.fetchAssessmentReports(
      patientId: widget.patientId,
    );
  }

  Future<void> _reload() async {
    final future = AdaptiveTherapyRepository.fetchAssessmentReports(
      patientId: widget.patientId,
    );
    setState(() => _reports = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    // This screen is used both inside the assessment module and as a pushed
    // route from the caregiver view. The pushed route has no Material parent,
    // while ExpansionTile requires one for ink/elevation/theme rendering.
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: FutureBuilder<List<AssessmentSessionReport>>(
          future: _reports,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError)
              return Center(
                child: Text(
                  'Reports are unavailable.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20),
                ),
              );
            final reports = snapshot.data ?? const <AssessmentSessionReport>[];
            final today = reports
                .where((report) => _isToday(report.completedAt))
                .toList();
            final todayReport = today.isEmpty ? null : today.first;
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        onPressed: () {
                          if (widget.onBack != null) {
                            widget.onBack!();
                          } else if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: TherapyColors.navy,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Assessment Reports',
                          style: TextStyle(
                            color: TherapyColors.navy,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Completed assessments only. Incomplete sessions are not shown here.',
                    style: TextStyle(
                      color: TherapyColors.body,
                      fontSize: 20,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (todayReport == null)
                    const TherapyCard(
                      color: Color(0xFFEAF4FF),
                      child: Text(
                        'No assessment completed today. Your score and activity details will appear here after you finish one.',
                        style: TextStyle(
                          color: TherapyColors.navy,
                          fontSize: 20,
                          height: 1.4,
                        ),
                      ),
                    )
                  else ...[
                    const Text(
                      'Today\'s assessment',
                      style: TextStyle(
                        color: TherapyColors.navy,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TherapyCard(
                      color: const Color(0xFFE7F7F1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Completed',
                                  style: TextStyle(
                                    color: TherapyColors.tealDark,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                '${todayReport.overallScore} / 100',
                                style: const TextStyle(
                                  color: TherapyColors.navy,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${todayReport.activityScores.length} of 3 activities completed',
                            style: const TextStyle(
                              color: TherapyColors.body,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...todayReport.activityScores.map(
                            (score) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      score.activityTitle,
                                      style: const TextStyle(
                                        color: TherapyColors.navy,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${score.score}%',
                                    style: const TextStyle(
                                      color: TherapyColors.tealDark,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                  if (reports.isEmpty)
                    const TherapyCard(
                      child: Text(
                        'No completed assessments yet.',
                        style: TextStyle(
                          color: TherapyColors.navy,
                          fontSize: 21,
                        ),
                      ),
                    )
                  else ...[
                    if (reports.length > 1) _ProgressSummary(reports: reports),
                    ...reports.map((report) => _ReportCard(report: report)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static bool _isToday(DateTime? value) {
    if (value == null) return false;
    final now = DateTime.now();
    final local = value.toLocal();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});
  final AssessmentSessionReport report;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TherapyCard(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 10),
        title: Text(
          '${report.overallScore} / 100',
          style: const TextStyle(
            color: TherapyColors.navy,
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          _date(report.completedAt!),
          style: const TextStyle(color: TherapyColors.body, fontSize: 18),
        ),
        children: report.activityScores
            .map(
              (score) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        score.activityTitle,
                        style: const TextStyle(
                          color: TherapyColors.navy,
                          fontSize: 19,
                        ),
                      ),
                    ),
                    Text(
                      '${score.score}%',
                      style: const TextStyle(
                        color: TherapyColors.tealDark,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    ),
  );

  static String _date(DateTime value) =>
      '${value.day}/${value.month}/${value.year}';
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.reports});
  final List<AssessmentSessionReport> reports;

  @override
  Widget build(BuildContext context) {
    final recent = reports.take(6).toList().reversed.toList();
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TherapyCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall progress history',
              style: TextStyle(
                color: TherapyColors.navy,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Oldest to newest assessment scores',
              style: TextStyle(color: TherapyColors.body, fontSize: 18),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 150,
              child: CustomPaint(
                painter: _ProgressPainter(
                  scores: recent.map((item) => item.overallScore).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: recent
                  .map(
                    (report) => Text(
                      _ProgressPainter.shortDate(report.completedAt!),
                      style: const TextStyle(
                        color: TherapyColors.muted,
                        fontSize: 13,
                      ),
                    ),
                  )
                  .toList(),
            ),
            if (reports.length > 1) ...[
              const SizedBox(height: 12),
              Text(
                _ProgressPainter.trendText(reports),
                style: const TextStyle(
                  color: TherapyColors.body,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  const _ProgressPainter({required this.scores});
  final List<int> scores;

  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = TherapyColors.primary
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final dot = Paint()..color = TherapyColors.tealDark;
    if (scores.length < 2) return;
    final path = Path();
    for (var index = 0; index < scores.length; index++) {
      final x = index * size.width / (scores.length - 1);
      final y = size.height - (scores[index] / 100 * size.height);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 7, dot);
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) =>
      oldDelegate.scores != scores;

  static String shortDate(DateTime value) => '${value.day}/${value.month}';

  static String trendText(List<AssessmentSessionReport> reports) {
    final change = reports.first.overallScore - reports[1].overallScore;
    if (change == 0)
      return 'Your latest score is the same as the previous session.';
    if (change > 0)
      return 'Your latest score is $change points higher than the previous session.';
    return 'Your latest score is ${change.abs()} points lower than the previous session.';
  }
}

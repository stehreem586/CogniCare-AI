import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/therapy_models.dart';
import '../../data/repositories/adaptive_therapy_repository.dart';
import '../../services/assessment_service.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';
import 'assessment_activity_screen.dart';

class AssessmentSessionScreen extends StatefulWidget {
  const AssessmentSessionScreen({
    super.key,
    this.activities,
    this.previousCombinations = const [],
    required this.onFinished,
  });

  final List<AssessmentActivityDefinition>? activities;
  final List<Set<String>> previousCombinations;
  final ValueChanged<AssessmentSessionReport> onFinished;

  @override
  State<AssessmentSessionScreen> createState() => _AssessmentSessionScreenState();
}

class _AssessmentSessionScreenState extends State<AssessmentSessionScreen> {
  late final List<AssessmentActivityDefinition> _activities;
  late final String _patientId;
  late final String _sessionId;
  late final DateTime _startedAt = DateTime.now();
  final List<AssessmentActivityScore> _scores = [];
  int _index = 0;
  bool _isStarting = true;
  Object? _startError;

  @override
  void initState() {
    super.initState();
    _activities = widget.activities ?? AssessmentService.selectActivities(previousCombinations: widget.previousCombinations);
    try {
      _patientId = AdaptiveTherapyRepository.requireAuthenticatedPatientId();
      _sessionId = 'assessment-${DateTime.now().microsecondsSinceEpoch}';
      _createSession();
    } catch (error) {
      _patientId = '';
      _sessionId = '';
      _startError = error;
      _isStarting = false;
    }
  }

  Future<void> _createSession() async {
    try {
      await AdaptiveTherapyRepository.createAssessmentSession(
        sessionId: _sessionId,
        patientId: _patientId,
        activities: _activities,
      );
    } catch (error) {
      _startError = error;
    }
    if (mounted) setState(() => _isStarting = false);
  }

  Future<void> _activityFinished(AssessmentActivityScore score) async {
    _scores.add(score);
    try {
      await AdaptiveTherapyRepository.saveAssessmentScore(sessionId: _sessionId, score: score);
    } catch (_) {
      // The final report remains available locally; the next sync can retry it.
    }

    if (_index < _activities.length - 1) {
      setState(() {
        _index++;
      });
      return;
    }

    final report = AssessmentSessionReport(
      sessionId: _sessionId,
      patientId: _patientId,
      activityScores: List.unmodifiable(_scores),
      overallScore: AssessmentService.overallScore(_scores),
      startedAt: _startedAt,
      completedAt: DateTime.now(),
      status: 'completed',
    );
    try {
      await AdaptiveTherapyRepository.completeAssessmentSession(report: report);
    } catch (_) {
      // Keep the result screen usable even if the network is temporarily down.
    }
    if (!mounted) return;
    widget.onFinished(report);
  }

  @override
  Widget build(BuildContext context) {
    if (_isStarting) {
      return const TherapyPage(child: Center(child: CircularProgressIndicator()));
    }
    if (_startError != null) {
      return TherapyPage(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Please sign in before starting an assessment.\n\n$_startError',
              textAlign: TextAlign.center,
              style: const TextStyle(color: TherapyColors.navy, fontSize: 20),
            ),
          ),
        ),
      );
    }

    return AssessmentActivityScreen(
      key: ValueKey('$_sessionId-$_index'),
      definition: _activities[_index],
      activityNumber: _index + 1,
      totalActivities: _activities.length,
      onComplete: _activityFinished,
    );
  }
}

class AssessmentResultsScreen extends StatelessWidget {
  const AssessmentResultsScreen({super.key, required this.report, required this.onDone});

  final AssessmentSessionReport report;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return TherapyPage(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            const TherapyBackHeader(title: 'Assessment Results'),
            const SizedBox(height: 10),
            const Text('Assessment complete', style: TextStyle(color: TherapyColors.navy, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Completed ${_date(report.completedAt!)}', style: const TextStyle(color: TherapyColors.body, fontSize: 20)),
            const SizedBox(height: 20),
            TherapyCard(
              color: const Color(0xFFE7F7F1),
              child: Column(
                children: [
                  const Text('Overall cognitive score', style: TextStyle(color: TherapyColors.body, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('${report.overallScore} / 100', style: const TextStyle(color: TherapyColors.navy, fontSize: 42, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: report.overallScore / 100, minHeight: 14, color: TherapyColors.primary, backgroundColor: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Activity scores', style: TextStyle(color: TherapyColors.navy, fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ...report.activityScores.map((score) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TherapyCard(
                    child: Row(
                      children: [
                        Expanded(child: Text(score.activityTitle, style: const TextStyle(color: TherapyColors.navy, fontSize: 20, fontWeight: FontWeight.w700))),
                        Text('${score.score}%', style: const TextStyle(color: TherapyColors.tealDark, fontSize: 24, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 18),
            SizedBox(height: 64, child: ElevatedButton(onPressed: onDone, style: ElevatedButton.styleFrom(backgroundColor: TherapyColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('Back to assessments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)))),
          ],
        ),
      ),
    );
  }

  static String _date(DateTime value) => '${value.day}/${value.month}/${value.year}';
}

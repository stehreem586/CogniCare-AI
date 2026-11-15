import 'package:flutter/material.dart';

import '../../app/routes.dart';
import 'data/repositories/adaptive_therapy_repository.dart';
import 'data/models/therapy_models.dart';
import 'presentation/screens/assessment_home_screen.dart';
import 'presentation/screens/assessment_reports_screen.dart';
import 'presentation/screens/assessment_session_screen.dart';
import 'presentation/theme/therapy_colors.dart';
import 'presentation/widgets/therapy_bottom_nav.dart';
import 'services/assessment_service.dart';

class AssessmentModule extends StatefulWidget {
  const AssessmentModule({super.key, this.initialTab = TherapyModuleTab.home});

  final TherapyModuleTab initialTab;

  @override
  State<AssessmentModule> createState() => _AssessmentModuleState();
}

class _AssessmentModuleState extends State<AssessmentModule> {
  late Future<_AssessmentLoad> _load;

  @override
  void initState() {
    super.initState();
    _load = _loadAssessmentData();
  }

  Future<_AssessmentLoad> _loadAssessmentData() async {
    final patientId = AdaptiveTherapyRepository.requireAuthenticatedPatientId();
    final combinations = await AdaptiveTherapyRepository.fetchCompletedActivityCombinations(patientId: patientId);
    final reports = await AdaptiveTherapyRepository.fetchAssessmentReports(patientId: patientId);
    final selected = AssessmentService.selectActivities(previousCombinations: combinations);
    return _AssessmentLoad(patientId: patientId, previousCombinations: combinations, reports: reports, selectedActivities: selected);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_AssessmentLoad>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const _ModuleState(child: Center(child: CircularProgressIndicator()));
          if (snapshot.hasError || !snapshot.hasData) {
            return _ModuleState(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Please sign in to use cognitive assessments.\n\n${snapshot.error ?? ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: TherapyColors.navy, fontSize: 21),
                  ),
                ),
              ),
            );
          }
          return _AssessmentShell(load: snapshot.data!, initialTab: widget.initialTab);
        },
      );
}

class _AssessmentShell extends StatefulWidget {
  const _AssessmentShell({required this.load, required this.initialTab});
  final _AssessmentLoad load;
  final TherapyModuleTab initialTab;

  @override
  State<_AssessmentShell> createState() => _AssessmentShellState();
}

class _AssessmentShellState extends State<_AssessmentShell> {
  late TherapyModuleTab _tab = widget.initialTab;
  late List<AssessmentActivityDefinition> _selectedActivities = widget.load.selectedActivities;
  late List<AssessmentSessionReport> _reports = widget.load.reports;

  void _startAssessment() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => AssessmentSessionScreen(
        activities: _selectedActivities,
        onFinished: (report) {
          setState(() {
            _reports = [report, ..._reports];
            _selectedActivities = AssessmentService.selectActivities(
              previousCombinations: [
                ...widget.load.previousCombinations,
                {for (final activity in report.activityScores) activity.activityId},
              ],
            );
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => AssessmentResultsScreen(report: report, onDone: () => Navigator.of(context).pop())));
        },
      ),
    ));
  }

  void _setTab(int index) {
    final tab = TherapyModuleTab.values[index];
    if (tab == TherapyModuleTab.profile) {
      Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.patientProfile);
      return;
    }
    setState(() => _tab = tab);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      AssessmentHomeScreen(reports: _reports, onStart: _startAssessment, onReports: () => _setTab(TherapyModuleTab.reports.index)),
      AssessmentReportsScreen(key: ValueKey('${widget.load.patientId}-reports-${_reports.length}'), patientId: widget.load.patientId),
      const SizedBox.shrink(),
      _MoreAssessmentTab(onReports: () => _setTab(TherapyModuleTab.reports.index)),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab.index, children: pages),
      bottomNavigationBar: TherapyBottomNav(index: _tab.index, onTap: _setTab),
    );
  }
}

class _MoreAssessmentTab extends StatelessWidget {
  const _MoreAssessmentTab({required this.onReports});
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('More', style: TextStyle(color: TherapyColors.navy, fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            _MoreButton(label: 'Assessment reports', icon: Icons.history_rounded, onPressed: onReports),
          ],
        ),
      );
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 30),
        label: Text(label, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(64), alignment: Alignment.centerLeft, foregroundColor: TherapyColors.primary, side: const BorderSide(color: TherapyColors.primary, width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      );
}

class _AssessmentLoad {
  const _AssessmentLoad({required this.patientId, required this.previousCombinations, required this.reports, required this.selectedActivities});
  final String patientId;
  final List<Set<String>> previousCombinations;
  final List<AssessmentSessionReport> reports;
  final List<AssessmentActivityDefinition> selectedActivities;
}

class _ModuleState extends StatelessWidget {
  const _ModuleState({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(body: child);
}

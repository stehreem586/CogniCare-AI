import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/therapy_models.dart';
import '../seed/sample_therapy_seed.dart';

class AdaptiveTherapyRepository {
  AdaptiveTherapyRepository._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _activitiesCollection = 'therapyActivities';
  static const String _recommendationsCollection = 'therapyRecommendations';
  static const String _sessionsCollection = 'activitySessions';
  static const String _preferencesCollection = 'patientPreferences';
  static const String _feedbackCollection = 'activityFeedback';
  static const String _assessmentSessionsCollection = 'assessmentSessions';

  static String currentPatientId({String? patientId}) {
    final explicitId = patientId?.trim();
    if (explicitId != null && explicitId.isNotEmpty) {
      return explicitId;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }

    return 'preview-session-user';
  }

  static String requireAuthenticatedPatientId() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || userId.isEmpty) {
      throw StateError('A signed-in patient is required to start an assessment.');
    }
    return userId;
  }

  static Future<List<Set<String>>> fetchCompletedActivityCombinations({
    required String patientId,
  }) async {
    final snapshot = await _firestore
        .collection(_assessmentSessionsCollection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'completed')
        .get();
    return snapshot.docs.map((doc) {
      final ids = doc.data()['activityIds'] as List<dynamic>? ?? const [];
      return ids.map((id) => id.toString()).toSet();
    }).toList();
  }

  static Future<String> createAssessmentSession({
    String? sessionId,
    required String patientId,
    required List<AssessmentActivityDefinition> activities,
  }) async {
    final id = sessionId ?? 'assessment-${DateTime.now().microsecondsSinceEpoch}';
    final session = AssessmentSessionReport(
      sessionId: id,
      patientId: patientId,
      activityScores: const [],
      overallScore: 0,
      startedAt: DateTime.now(),
      completedAt: null,
      status: 'incomplete',
    );
    await _firestore.collection(_assessmentSessionsCollection).doc(id).set({
      ...session.toMap(),
      'activityIds': activities.map((activity) => activity.id).toList(),
    });
    return id;
  }

  static Future<void> saveAssessmentScore({
    required String sessionId,
    required AssessmentActivityScore score,
  }) async {
    await _firestore.collection(_assessmentSessionsCollection).doc(sessionId).update({
      'activityScores': FieldValue.arrayUnion([score.toMap()]),
    });
  }

  static Future<void> completeAssessmentSession({
    required AssessmentSessionReport report,
  }) async {
    await _firestore
        .collection(_assessmentSessionsCollection)
        .doc(report.sessionId)
        .set(report.toMap(), SetOptions(merge: true));
  }

  static Future<List<AssessmentSessionReport>> fetchAssessmentReports({
    required String patientId,
  }) async {
    final snapshot = await _firestore
        .collection(_assessmentSessionsCollection)
        .where('patientId', isEqualTo: patientId)
        .where('status', isEqualTo: 'completed')
        .get();
      final reports = snapshot.docs
        .map((doc) => AssessmentSessionReport.fromMap(doc.data()))
        .where((report) => report.isComplete)
        .toList();
      reports.sort((a, b) => (b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0))
        .compareTo(a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0)));
      return reports;
  }

  static Future<void> seedSampleActivities() async {
    try {
      final snapshot = await _firestore.collection(_activitiesCollection).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        return;
      }

      final batch = _firestore.batch();
      for (final activity in SampleTherapySeed.activities) {
        batch.set(
          _firestore.collection(_activitiesCollection).doc(activity.id),
          activity.toFirestore(),
        );
      }
      await batch.commit();
    } catch (error) {
      debugPrint('Seed skipped: $error');
    }
  }

  static Future<List<TherapyActivity>> fetchActivities({String? category}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection(_activitiesCollection)
          .where('isActive', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      final docs = snapshot.docs;
      if (docs.isEmpty) {
        await seedSampleActivities();
        return SampleTherapySeed.activities;
      }

      final activities = docs
          .map((doc) => TherapyActivity.fromFirestore(doc.data()))
          .toList();
      if (activities.isEmpty) {
        return SampleTherapySeed.activities;
      }

      if (category == null || category == 'Games') {
        final activityIds = activities.map((activity) => activity.id).toSet();
        activities.addAll(
          SampleTherapySeed.activities.where(
            (activity) =>
                activity.category == 'Games' && !activityIds.contains(activity.id),
          ),
        );
      }
      return activities;
    } catch (error) {
      debugPrint('Firestore fetch failed, using local seed data: $error');
      return SampleTherapySeed.activities;
    }
  }

  static Future<List<TherapyTypeItem>> fetchTherapyTypes({String? patientId}) async {
    final activities = await fetchActivities();
    return activities.map((activity) {
      return TherapyTypeItem(
        title: activity.category,
        subtitle: activity.title,
        iconKind: activity.iconKind,
        routeName: activity.category.toLowerCase().contains('relax')
            ? '/activity-detail'
            : activity.category.toLowerCase().contains('game')
                ? '/cognitive-game'
                : activity.category.toLowerCase().contains('music')
                    ? '/activity-detail'
                    : '/memory-exercise',
      );
    }).toList();
  }

  static Future<PatientPreference> fetchPatientPreference({String? patientId}) async {
    final patientIdValue = currentPatientId(patientId: patientId);

    try {
      final doc = await _firestore
          .collection(_preferencesCollection)
          .doc(patientIdValue)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return PatientPreference(
          patientId: patientIdValue,
          preferredMood: (data['preferredMood'] ?? 'Calm').toString(),
          preferredCategory: (data['preferredCategory'] ?? 'Relaxation').toString(),
          confidence: (data['confidence'] ?? 75) as int,
          favoriteTherapies: List<String>.from(data['favoriteTherapies'] as List<dynamic>? ?? const <dynamic>[]),
          recentScores: List<double>.from((data['recentScores'] as List<dynamic>? ?? const <dynamic>[]).map((item) => double.tryParse(item.toString()) ?? 0.0)),
        );
      }
    } catch (error) {
      debugPrint('Preference read failed: $error');
    }

    return PatientPreference(
      patientId: patientIdValue,
      preferredMood: 'Calm',
      preferredCategory: 'Relaxation',
      confidence: 78,
      favoriteTherapies: const ['Relaxation', 'Games', 'Music'],
      recentScores: const [0.64, 0.71, 0.82],
    );
  }

  static Future<void> savePatientPreference(PatientPreference preference) async {
    try {
      await _firestore
          .collection(_preferencesCollection)
          .doc(preference.patientId)
          .set(preference.toFirestore(), SetOptions(merge: true));
    } catch (error) {
      debugPrint('Preference save failed: $error');
    }
  }

  static Future<void> saveActivitySession(ActivitySession session) async {
    try {
      await _firestore
          .collection(_sessionsCollection)
          .add(session.toFirestore());
    } catch (error) {
      debugPrint('Session save failed: $error');
    }
  }

  static Future<void> saveActivityFeedback(ActivityFeedback feedback) async {
    try {
      await _firestore
          .collection(_feedbackCollection)
          .add(feedback.toFirestore());
    } catch (error) {
      debugPrint('Feedback save failed: $error');
    }
  }

  static Future<void> saveRecommendation(TherapyRecommendation recommendation) async {
    try {
      await _firestore
          .collection(_recommendationsCollection)
          .add(recommendation.toFirestore());
    } catch (error) {
      debugPrint('Recommendation save failed: $error');
    }
  }
}

enum TherapyDifficulty { easy, medium, hard }

enum TherapyModuleTab { home, reports, profile, more }

enum AssessmentActivityKind {
  story,
  cardMatching,
  numericalSequence,
  objectLocation,
  delayedRecall,
  patternRecall,
  everydayObjects,
}

class AssessmentActivityDefinition {
  const AssessmentActivityDefinition({
    required this.id,
    required this.title,
    required this.kind,
    required this.instruction,
  });

  final String id;
  final String title;
  final AssessmentActivityKind kind;
  final String instruction;
}

class AssessmentActivityScore {
  const AssessmentActivityScore({
    required this.activityId,
    required this.activityTitle,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.score,
    required this.completedAt,
  });

  final String activityId;
  final String activityTitle;
  final int correctAnswers;
  final int totalQuestions;
  final int score;
  final DateTime completedAt;

  Map<String, dynamic> toMap() => {
        'activityId': activityId,
        'activityTitle': activityTitle,
        'correctAnswers': correctAnswers,
        'totalQuestions': totalQuestions,
        'score': score,
        'completedAt': completedAt.toUtc().toIso8601String(),
      };

  factory AssessmentActivityScore.fromMap(Map<String, dynamic> map) {
    return AssessmentActivityScore(
      activityId: '${map['activityId'] ?? ''}',
      activityTitle: '${map['activityTitle'] ?? 'Assessment activity'}',
      correctAnswers: (map['correctAnswers'] as num? ?? 0).toInt(),
      totalQuestions: (map['totalQuestions'] as num? ?? 0).toInt(),
      score: (map['score'] as num? ?? 0).toInt(),
      completedAt: DateTime.tryParse('${map['completedAt'] ?? ''}') ?? DateTime.now(),
    );
  }
}

class AssessmentSessionReport {
  const AssessmentSessionReport({
    required this.sessionId,
    required this.patientId,
    required this.activityScores,
    required this.overallScore,
    required this.startedAt,
    required this.completedAt,
    required this.status,
  });

  final String sessionId;
  final String patientId;
  final List<AssessmentActivityScore> activityScores;
  final int overallScore;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String status;

  bool get isComplete => status == 'completed' && activityScores.length == 3;

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'patientId': patientId,
        'activityIds': activityScores.map((item) => item.activityId).toList(),
        'activityScores': activityScores.map((item) => item.toMap()).toList(),
        'overallScore': overallScore,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'completedAt': completedAt?.toUtc().toIso8601String(),
        'status': status,
      };

  factory AssessmentSessionReport.fromMap(Map<String, dynamic> map) {
    final rawScores = map['activityScores'] as List<dynamic>? ?? const [];
    return AssessmentSessionReport(
      sessionId: '${map['sessionId'] ?? ''}',
      patientId: '${map['patientId'] ?? ''}',
      activityScores: rawScores
          .whereType<Map<String, dynamic>>()
          .map(AssessmentActivityScore.fromMap)
          .toList(),
      overallScore: (map['overallScore'] as num? ?? 0).toInt(),
      startedAt: DateTime.tryParse('${map['startedAt'] ?? ''}') ?? DateTime.now(),
      completedAt: map['completedAt'] == null
          ? null
          : DateTime.tryParse('${map['completedAt']}'),
      status: '${map['status'] ?? 'incomplete'}',
    );
  }
}

class TherapyActivity {
  const TherapyActivity({
    required this.id,
    required this.title,
    required this.category,
    required this.durationLabel,
    required this.description,
    required this.benefits,
    required this.iconKind,
    this.difficulty = TherapyDifficulty.easy,
    this.isActive = true,
  });

  final String id;
  final String title;
  final String category;
  final String durationLabel;
  final String description;
  final List<String> benefits;
  final TherapyIconKind iconKind;
  final TherapyDifficulty difficulty;
  final bool isActive;

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'durationLabel': durationLabel,
      'description': description,
      'benefits': benefits,
      'iconKind': iconKind.name,
      'difficulty': difficulty.name,
      'isActive': isActive,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  factory TherapyActivity.fromFirestore(Map<String, dynamic> map) {
    return TherapyActivity(
      id: (map['id'] ?? map['activityId'] ?? '').toString(),
      title: (map['title'] ?? 'Therapy Activity').toString(),
      category: (map['category'] ?? 'General').toString(),
      durationLabel: (map['durationLabel'] ?? '5 min').toString(),
      description: (map['description'] ?? '').toString(),
      benefits: List<String>.from((map['benefits'] as List<dynamic>? ?? const <dynamic>[]).map((item) => item.toString())),
      iconKind: TherapyIconKind.values.firstWhere(
        (kind) => kind.name == (map['iconKind'] ?? 'leaf'),
        orElse: () => TherapyIconKind.leaf,
      ),
      difficulty: TherapyDifficulty.values.firstWhere(
        (level) => level.name == (map['difficulty'] ?? 'easy'),
        orElse: () => TherapyDifficulty.easy,
      ),
      isActive: map['isActive'] ?? true,
    );
  }
}

enum TherapyIconKind { leaf, games, mindfulness, reminiscence, routine }

class TherapyTypeItem {
  const TherapyTypeItem({
    required this.title,
    required this.subtitle,
    required this.iconKind,
    required this.routeName,
    this.activityId,
  });

  final String title;
  final String subtitle;
  final TherapyIconKind iconKind;
  final String routeName;
  final String? activityId;
}

class TherapyRecommendation {
  const TherapyRecommendation({
    required this.patientId,
    required this.activityId,
    required this.activityTitle,
    required this.category,
    required this.reason,
    required this.generatedAt,
    required this.difficulty,
  });

  final String patientId;
  final String activityId;
  final String activityTitle;
  final String category;
  final String reason;
  final DateTime generatedAt;
  final TherapyDifficulty difficulty;

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'activityId': activityId,
      'activityTitle': activityTitle,
      'category': category,
      'reason': reason,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'difficulty': difficulty.name,
    };
  }
}

class ActivitySession {
  const ActivitySession({
    required this.patientId,
    required this.activityId,
    required this.category,
    required this.activityTitle,
    required this.startedAt,
    this.completedAt,
    required this.difficulty,
    required this.performanceScore,
    required this.durationSeconds,
  });

  final String patientId;
  final String activityId;
  final String category;
  final String activityTitle;
  final DateTime startedAt;
  final DateTime? completedAt;
  final TherapyDifficulty difficulty;
  final double performanceScore;
  final int durationSeconds;

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'activityId': activityId,
      'category': category,
      'activityTitle': activityTitle,
      'startedAt': startedAt.toUtc().toIso8601String(),
      'completedAt': (completedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'difficulty': difficulty.name,
      'performanceScore': performanceScore,
      'durationSeconds': durationSeconds,
    };
  }
}

class TherapyActivityResult {
  const TherapyActivityResult({
    required this.activityId,
    required this.activityTitle,
    required this.category,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.elapsedSeconds,
    required this.difficulty,
  });

  final String activityId;
  final String activityTitle;
  final String category;
  final int correctAnswers;
  final int totalQuestions;
  final int elapsedSeconds;
  final TherapyDifficulty difficulty;

  int get percentage => totalQuestions == 0
      ? 0
      : ((correctAnswers / totalQuestions) * 100).round();
}

class PatientPreference {
  const PatientPreference({
    required this.patientId,
    required this.preferredMood,
    required this.preferredCategory,
    required this.confidence,
    required this.favoriteTherapies,
    required this.recentScores,
  });

  final String patientId;
  final String preferredMood;
  final String preferredCategory;
  final int confidence;
  final List<String> favoriteTherapies;
  final List<double> recentScores;

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'preferredMood': preferredMood,
      'preferredCategory': preferredCategory,
      'confidence': confidence,
      'favoriteTherapies': favoriteTherapies,
      'recentScores': recentScores,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}

class ActivityFeedback {
  const ActivityFeedback({
    required this.patientId,
    required this.activityId,
    required this.rating,
    required this.comment,
    required this.sentiment,
    required this.createdAt,
  });

  final String patientId;
  final String activityId;
  final double rating;
  final String comment;
  final String sentiment;
  final DateTime createdAt;

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'activityId': activityId,
      'rating': rating,
      'comment': comment,
      'sentiment': sentiment,
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}

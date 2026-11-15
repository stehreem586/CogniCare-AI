import '../../../../core/utils/date_utils.dart';

class HealthProfile {
  final String dementiaStage;
  final String medicalHistory;
  final String careNotes;
  final DateTime? updatedAt;

  const HealthProfile({
    this.dementiaStage = 'Mild',
    this.medicalHistory = '',
    this.careNotes = '',
    this.updatedAt,
  });

  factory HealthProfile.fromMap(Map<String, dynamic> map) {
    return HealthProfile(
      dementiaStage: map['dementiaStage'] ?? 'Mild',
      medicalHistory: map['medicalHistory'] ?? '',
      careNotes: map['careNotes'] ?? '',
      updatedAt: AppDateUtils.fromTimestamp(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dementiaStage': dementiaStage,
      'medicalHistory': medicalHistory,
      'careNotes': careNotes,
      'updatedAt': AppDateUtils.toTimestamp(updatedAt ?? DateTime.now()),
    };
  }

  HealthProfile copyWith({
    String? dementiaStage,
    String? medicalHistory,
    String? careNotes,
    DateTime? updatedAt,
  }) {
    return HealthProfile(
      dementiaStage: dementiaStage ?? this.dementiaStage,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      careNotes: careNotes ?? this.careNotes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

import '../../../../core/utils/date_utils.dart';

class CaregiverPatientLink {
  final String id;
  final String caregiverId;
  final String patientId;
  final DateTime? createdAt;

  const CaregiverPatientLink({
    required this.id,
    required this.caregiverId,
    required this.patientId,
    this.createdAt,
  });

  factory CaregiverPatientLink.fromMap(Map<String, dynamic> map, [String? docId]) {
    return CaregiverPatientLink(
      id: docId ?? map['id'] ?? '',
      caregiverId: map['caregiverId'] ?? '',
      patientId: map['patientId'] ?? '',
      createdAt: AppDateUtils.fromTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caregiverId': caregiverId,
      'patientId': patientId,
      'createdAt': AppDateUtils.toTimestamp(createdAt),
    };
  }
}

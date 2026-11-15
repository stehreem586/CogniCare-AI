import '../../../../core/utils/date_utils.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String relationship;
  final String phone;
  final DateTime? createdAt;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.createdAt,
  });

  factory EmergencyContact.fromMap(Map<String, dynamic> map, [String? docId]) {
    return EmergencyContact(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      relationship: map['relationship'] ?? '',
      phone: map['phone'] ?? map['phoneNumber'] ?? '',
      createdAt: AppDateUtils.fromTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'createdAt': AppDateUtils.toTimestamp(createdAt),
    };
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? relationship,
    String? phone,
    DateTime? createdAt,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

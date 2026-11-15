import '../../../../core/utils/date_utils.dart';

class UserProfile {
  final String uid;
  final String role;
  final String name;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final DateTime? createdAt;

  const UserProfile({
    required this.uid,
    required this.role,
    required this.name,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, [String? docId]) {
    return UserProfile(
      uid: docId ?? map['uid'] ?? '',
      role: map['role'] ?? 'patient',
      name: map['name'] ?? map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? map['phoneNumber'],
      dateOfBirth: map['dateOfBirth'],
      createdAt: AppDateUtils.fromTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'createdAt': AppDateUtils.toTimestamp(createdAt),
    };
  }

  UserProfile copyWith({
    String? uid,
    String? role,
    String? name,
    String? email,
    String? phone,
    String? dateOfBirth,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

import '../../../../core/utils/date_utils.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final String role;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, [String? docId]) {
    return AppUser(
      uid: docId ?? map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? map['displayName'] ?? '',
      role: map['role'] ?? 'patient',
      createdAt: AppDateUtils.fromTimestamp(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'createdAt': AppDateUtils.toTimestamp(createdAt),
    };
  }

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

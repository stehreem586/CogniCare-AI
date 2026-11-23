import 'package:cloud_firestore/cloud_firestore.dart';

class MemoryModel {
  final String id;
  final String patientId;
  final String caregiverId;
  final String title;
  final String? photoUrl;
  final String? photoBase64;
  final String? localImagePath;
  final String? illustrationKey;
  final DateTime date;
  final String place;
  final String era; // 'Childhood', 'Adulthood', 'Recent'
  final List<String> taggedPeople;
  final String? audioPath;
  final int audioDurationSeconds;
  final List<String> aiSuggestions;
  final DateTime createdAt;
  final bool isFavorite;

  const MemoryModel({
    required this.id,
    required this.patientId,
    this.caregiverId = '',
    required this.title,
    this.photoUrl,
    this.photoBase64,
    this.localImagePath,
    this.illustrationKey,
    required this.date,
    required this.place,
    this.era = 'Childhood',
    this.taggedPeople = const [],
    this.audioPath,
    this.audioDurationSeconds = 0,
    this.aiSuggestions = const [],
    required this.createdAt,
    this.isFavorite = false,
  });

  factory MemoryModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parsedDate;
    final rawDate = map['date'];
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    DateTime parsedCreated;
    final rawCreated = map['createdAt'];
    if (rawCreated is Timestamp) {
      parsedCreated = rawCreated.toDate();
    } else if (rawCreated is String) {
      parsedCreated = DateTime.tryParse(rawCreated) ?? DateTime.now();
    } else {
      parsedCreated = DateTime.now();
    }

    return MemoryModel(
      id: docId ?? map['id'] as String? ?? '',
      patientId: map['patientId'] as String? ?? '',
      caregiverId: map['caregiverId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      photoUrl: map['photoUrl'] as String?,
      photoBase64: map['photoBase64'] as String?,
      localImagePath: map['localImagePath'] as String?,
      illustrationKey: map['illustrationKey'] as String?,
      date: parsedDate,
      place: map['place'] as String? ?? '',
      era: map['era'] as String? ?? 'Childhood',
      taggedPeople:
          (map['taggedPeople'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      audioPath: map['audioPath'] as String?,
      audioDurationSeconds: (map['audioDurationSeconds'] as num?)?.toInt() ?? 0,
      aiSuggestions:
          (map['aiSuggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: parsedCreated,
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'caregiverId': caregiverId,
      'title': title,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (photoBase64 != null) 'photoBase64': photoBase64,
      if (localImagePath != null) 'localImagePath': localImagePath,
      if (illustrationKey != null) 'illustrationKey': illustrationKey,
      'date': Timestamp.fromDate(date),
      'place': place,
      'era': era,
      'taggedPeople': taggedPeople,
      if (audioPath != null) 'audioPath': audioPath,
      'audioDurationSeconds': audioDurationSeconds,
      'aiSuggestions': aiSuggestions,
      'createdAt': Timestamp.fromDate(createdAt),
      'isFavorite': isFavorite,
    };
  }

  MemoryModel copyWith({
    String? id,
    String? patientId,
    String? caregiverId,
    String? title,
    String? photoUrl,
    String? photoBase64,
    String? localImagePath,
    String? illustrationKey,
    DateTime? date,
    String? place,
    String? era,
    List<String>? taggedPeople,
    String? audioPath,
    int? audioDurationSeconds,
    List<String>? aiSuggestions,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return MemoryModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      caregiverId: caregiverId ?? this.caregiverId,
      title: title ?? this.title,
      photoUrl: photoUrl ?? this.photoUrl,
      photoBase64: photoBase64 ?? this.photoBase64,
      localImagePath: localImagePath ?? this.localImagePath,
      illustrationKey: illustrationKey ?? this.illustrationKey,
      date: date ?? this.date,
      place: place ?? this.place,
      era: era ?? this.era,
      taggedPeople: taggedPeople ?? this.taggedPeople,
      audioPath: audioPath ?? this.audioPath,
      audioDurationSeconds: audioDurationSeconds ?? this.audioDurationSeconds,
      aiSuggestions: aiSuggestions ?? this.aiSuggestions,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

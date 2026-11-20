/// Model representing an AI-generated or caregiver-curated memory recall prompt.
class RecallPromptModel {
  final String id;
  final String memoryId;
  final String memoryTitle;
  final String? illustrationKey;
  final String? localImagePath;
  final String? photoBase64;
  final String? photoUrl;
  final String question;
  final String difficulty; // 'Easy', 'Medium', 'Hard'
  final String scheduledTime; // e.g. '5:00 PM'
  final String status; // 'pending', 'sent', 'completed'
  final List<String> suggestedAnswers;
  final String? targetEntity; // e.g. 'Nani', 'Ayesha', 'Lahore'
  final DateTime createdAt;

  const RecallPromptModel({
    required this.id,
    required this.memoryId,
    required this.memoryTitle,
    this.illustrationKey,
    this.localImagePath,
    this.photoBase64,
    this.photoUrl,
    required this.question,
    this.difficulty = 'Medium',
    this.scheduledTime = '5:00 PM',
    this.status = 'pending',
    this.suggestedAnswers = const [],
    this.targetEntity,
    required this.createdAt,
  });

  RecallPromptModel copyWith({
    String? id,
    String? memoryId,
    String? memoryTitle,
    String? illustrationKey,
    String? localImagePath,
    String? photoBase64,
    String? photoUrl,
    String? question,
    String? difficulty,
    String? scheduledTime,
    String? status,
    List<String>? suggestedAnswers,
    String? targetEntity,
    DateTime? createdAt,
  }) {
    return RecallPromptModel(
      id: id ?? this.id,
      memoryId: memoryId ?? this.memoryId,
      memoryTitle: memoryTitle ?? this.memoryTitle,
      illustrationKey: illustrationKey ?? this.illustrationKey,
      localImagePath: localImagePath ?? this.localImagePath,
      photoBase64: photoBase64 ?? this.photoBase64,
      photoUrl: photoUrl ?? this.photoUrl,
      question: question ?? this.question,
      difficulty: difficulty ?? this.difficulty,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      status: status ?? this.status,
      suggestedAnswers: suggestedAnswers ?? this.suggestedAnswers,
      targetEntity: targetEntity ?? this.targetEntity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memoryId': memoryId,
      'memoryTitle': memoryTitle,
      'illustrationKey': illustrationKey,
      'localImagePath': localImagePath,
      'photoBase64': photoBase64,
      'photoUrl': photoUrl,
      'question': question,
      'difficulty': difficulty,
      'scheduledTime': scheduledTime,
      'status': status,
      'suggestedAnswers': suggestedAnswers,
      'targetEntity': targetEntity,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecallPromptModel.fromMap(Map<String, dynamic> map, String docId) {
    return RecallPromptModel(
      id: docId.isNotEmpty ? docId : (map['id'] ?? ''),
      memoryId: map['memoryId'] ?? '',
      memoryTitle: map['memoryTitle'] ?? '',
      illustrationKey: map['illustrationKey'],
      localImagePath: map['localImagePath'],
      photoBase64: map['photoBase64'],
      photoUrl: map['photoUrl'],
      question: map['question'] ?? '',
      difficulty: map['difficulty'] ?? 'Medium',
      scheduledTime: map['scheduledTime'] ?? '5:00 PM',
      status: map['status'] ?? 'pending',
      suggestedAnswers: List<String>.from(map['suggestedAnswers'] ?? []),
      targetEntity: map['targetEntity'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

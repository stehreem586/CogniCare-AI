import 'dart:math';
import '../models/memory_model.dart';
import '../models/recall_prompt_model.dart';

class RecallPromptService {
  static final RecallPromptService _instance = RecallPromptService._internal();
  factory RecallPromptService() => _instance;
  RecallPromptService._internal();

  List<RecallPromptModel> _prompts = [];
  String smartScheduleTime = '5:00 PM';

  List<RecallPromptModel> get prompts => List.unmodifiable(_prompts);

  /// Initializes seeded prompts matching design mockup (media_1795109518619_1f82d867.jpg)
  void initializeWithDefaults() {
    _prompts = [
      RecallPromptModel(
        id: 'prompt_1',
        memoryId: 'mem_1',
        memoryTitle: "Eid at Nani's house",
        illustrationKey: 'eid_house',
        question: 'Do you remember who made sheer khurma on Eid morning?',
        difficulty: 'Easy',
        scheduledTime: smartScheduleTime,
        status: 'pending',
        targetEntity: "Nani",
        suggestedAnswers: ['Nani', 'Ayesha', 'Ammi', 'Auntie'],
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      RecallPromptModel(
        id: 'prompt_2',
        memoryId: 'mem_2',
        memoryTitle: 'Lahore Fort',
        illustrationKey: 'lahore_fort',
        question: 'Which city did you visit with Ayesha?',
        difficulty: 'Medium',
        scheduledTime: smartScheduleTime,
        status: 'pending',
        targetEntity: 'Lahore',
        suggestedAnswers: ['Lahore', 'Karachi', 'Islamabad', 'Murree'],
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      RecallPromptModel(
        id: 'prompt_3',
        memoryId: 'mem_5',
        memoryTitle: 'Wedding day',
        illustrationKey: 'wedding',
        question: 'What colour was your wedding sherwani?',
        difficulty: 'Medium',
        scheduledTime: smartScheduleTime,
        status: 'pending',
        targetEntity: 'Wedding',
        suggestedAnswers: [
          'Off-white / Gold',
          'Navy Blue',
          'Black',
          'Emerald Green',
        ],
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];
  }

  /// AI Prompt Generator: Creates contextual recall prompts from patient memories
  RecallPromptModel generatePromptFromMemories(List<MemoryModel> memories) {
    if (memories.isEmpty) {
      final fallback = RecallPromptModel(
        id: 'prompt_${DateTime.now().millisecondsSinceEpoch}',
        memoryId: 'mem_default',
        memoryTitle: 'Family memories',
        illustrationKey: 'eid_house',
        question: 'Do you remember your favorite childhood home?',
        difficulty: 'Easy',
        scheduledTime: smartScheduleTime,
        createdAt: DateTime.now(),
      );
      _prompts.insert(0, fallback);
      return fallback;
    }

    final random = Random();
    final memory = memories[random.nextInt(memories.length)];

    String question;
    String difficulty = 'Medium';
    String? target;

    if (memory.title.toLowerCase().contains('school')) {
      difficulty = 'Easy';
      question =
          'Do you remember your teacher\'s name on your first day of school?';
      target = 'School';
    } else if (memory.taggedPeople.isNotEmpty) {
      final person = memory.taggedPeople.first;
      target = person;
      final templates = [
        'Do you recall what you and $person loved laughing about?',
        'Can you remember when $person visited you in ${memory.place.isNotEmpty ? memory.place : 'the family house'}?',
        'What was $person\'s favorite dish that was cooked during family gatherings?',
      ];
      question = templates[random.nextInt(templates.length)];
      difficulty = 'Easy';
    } else if (memory.place.isNotEmpty) {
      target = memory.place;
      final templates = [
        'What was the weather like when you visited ${memory.place}?',
        'Do you remember the journey you took to get to ${memory.place}?',
      ];
      question = templates[random.nextInt(templates.length)];
      difficulty = 'Medium';
    } else {
      question = 'What was the most memorable part of ${memory.title}?';
      difficulty = 'Medium';
    }

    final newPrompt = RecallPromptModel(
      id: 'prompt_${DateTime.now().millisecondsSinceEpoch}',
      memoryId: memory.id,
      memoryTitle: memory.title,
      illustrationKey: memory.illustrationKey,
      localImagePath: memory.localImagePath,
      photoBase64: memory.photoBase64,
      photoUrl: memory.photoUrl,
      question: question,
      difficulty: difficulty,
      scheduledTime: smartScheduleTime,
      targetEntity: target,
      createdAt: DateTime.now(),
    );

    _prompts.insert(0, newPrompt);
    return newPrompt;
  }

  void updatePrompt(RecallPromptModel prompt) {
    final idx = _prompts.indexWhere((p) => p.id == prompt.id);
    if (idx >= 0) {
      _prompts[idx] = prompt;
    } else {
      _prompts.insert(0, prompt);
    }
  }

  void removePrompt(String promptId) {
    _prompts.removeWhere((p) => p.id == promptId);
  }

  void sendPrompt(String promptId) {
    final idx = _prompts.indexWhere((p) => p.id == promptId);
    if (idx >= 0) {
      _prompts[idx] = _prompts[idx].copyWith(status: 'sent');
    }
  }
}

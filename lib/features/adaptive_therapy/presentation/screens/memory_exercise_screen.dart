import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/mock_therapy_data.dart';
import '../../data/models/therapy_models.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';
import '../widgets/therapy_illustrations.dart';

class MemoryExerciseScreen extends StatefulWidget {
  const MemoryExerciseScreen({super.key, required this.onComplete});

  final ValueChanged<TherapyActivityResult> onComplete;

  @override
  State<MemoryExerciseScreen> createState() => _MemoryExerciseScreenState();
}

class _MemoryExerciseScreenState extends State<MemoryExerciseScreen> {
  static const _questions = [
    _MemoryQuestion(
      prompt: 'How many trees were in the park?',
      options: ['One', 'Two', 'Three', 'Four'],
      correctIndex: 1,
    ),
    _MemoryQuestion(
      prompt: 'Where was the bench?',
      options: ['Top left', 'Top right', 'Bottom left', 'Bottom right'],
      correctIndex: 3,
    ),
    _MemoryQuestion(
      prompt: 'What color was the path?',
      options: ['Green', 'Blue', 'Tan', 'Red'],
      correctIndex: 2,
    ),
  ];

  late final DateTime _startedAt = DateTime.now();
  int _seconds = 10;
  Timer? _timer;
  bool _isRecalling = false;
  int _questionIndex = 0;
  int _correctAnswers = 0;
  int? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();
        setState(() => _seconds = 0);
        return;
      }
      setState(() => _seconds -= 1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRecall() {
    if (_seconds > 0) return;
    setState(() => _isRecalling = true);
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;
    final question = _questions[_questionIndex];
    final score = _correctAnswers + (_selectedAnswer == question.correctIndex ? 1 : 0);

    if (_questionIndex == _questions.length - 1) {
      widget.onComplete(
        TherapyActivityResult(
          activityId: 'park-scene-recall',
          activityTitle: 'Park Scene Recall',
          category: 'Memory',
          correctAnswers: score,
          totalQuestions: _questions.length,
          elapsedSeconds: DateTime.now().difference(_startedAt).inSeconds,
          difficulty: TherapyDifficulty.easy,
        ),
      );
      return;
    }

    setState(() {
      _correctAnswers = score;
      _questionIndex += 1;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TherapyPage(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              const TherapyBackHeader(title: 'Memory Exercises'),
              if (!_isRecalling) ...[
                TherapyCard(
                  color: const Color(0xFFE7F7F1),
                  child: const Row(
                    children: [
                      Icon(Icons.visibility_rounded, color: TherapyColors.tealDark, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Study the park scene. You will answer three questions after the timer.',
                          style: TextStyle(color: TherapyColors.body, fontSize: 13, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: Stack(
                    children: [
                      const Positioned.fill(child: ParkMemoryScene()),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: TherapyBadge(label: '${_seconds}s'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                TherapyPrimaryButton(
                  label: _seconds == 0 ? 'Start recall' : 'Study the scene',
                  onPressed: _startRecall,
                ),
              ] else ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Question ${_questionIndex + 1} of ${_questions.length}',
                    style: const TextStyle(color: TherapyColors.body, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _questions[_questionIndex].prompt,
                    style: const TextStyle(color: TherapyColors.navy, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 18),
                for (var index = 0; index < _questions[_questionIndex].options.length; index++) ...[
                  _MemoryAnswerOption(
                    label: _questions[_questionIndex].options[index],
                    selected: _selectedAnswer == index,
                    onTap: () => setState(() => _selectedAnswer = index),
                  ),
                  if (index != _questions[_questionIndex].options.length - 1)
                    const SizedBox(height: 10),
                ],
                const Spacer(),
                TherapyPrimaryButton(
                  label: _questionIndex == _questions.length - 1 ? 'Finish' : 'Continue',
                  onPressed: () {
                    if (_selectedAnswer != null) _submitAnswer();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoryAnswerOption extends StatelessWidget {
  const _MemoryAnswerOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE7F7F1) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? TherapyColors.tealDark : const Color(0xFFD8E5EA),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: TherapyColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemoryQuestion {
  const _MemoryQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
}

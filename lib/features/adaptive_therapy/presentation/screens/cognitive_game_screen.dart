import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/therapy_models.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';

class CognitiveGameScreen extends StatefulWidget {
  const CognitiveGameScreen({
    super.key,
    required this.onComplete,
    this.activityId = 'card-matching',
    this.activityTitle,
    this.difficulty = TherapyDifficulty.medium,
  });

  final ValueChanged<TherapyActivityResult> onComplete;
  final String activityId;
  final String? activityTitle;
  final TherapyDifficulty difficulty;

  @override
  State<CognitiveGameScreen> createState() => _CognitiveGameScreenState();
}

class _CognitiveGameScreenState extends State<CognitiveGameScreen> {
  static const _story =
      'On Tuesday morning, Lina walked to the market with a blue basket. '
      'She bought oranges and bread, then met her neighbor Omar near the fountain. '
      'Before going home, Lina left the bread with her sister.';

  static const _cards = [
    _MatchCard(pair: 'sun', icon: Icons.wb_sunny_rounded),
    _MatchCard(pair: 'leaf', icon: Icons.eco_rounded),
    _MatchCard(pair: 'moon', icon: Icons.nightlight_round),
    _MatchCard(pair: 'moon', icon: Icons.nightlight_round),
    _MatchCard(pair: 'sun', icon: Icons.wb_sunny_rounded),
    _MatchCard(pair: 'leaf', icon: Icons.eco_rounded),
  ];

  late final DateTime _startedAt = DateTime.now();
  late final List<_RecallQuestion> _questions = _questionsFor(widget.activityId);
  final Set<int> _matchedCards = {};
  final List<int> _openCards = [];
  Timer? _mismatchTimer;
  int _questionIndex = 0;
  int _correctAnswers = 0;
  int _cardMistakes = 0;
  int? _selectedAnswer;
  bool _isStudying = true;
  bool _storyIntro = true;

  bool get _isCardMatch =>
      widget.activityId == 'card-matching' || widget.activityId == 'memory-match';

  String get _title => widget.activityTitle ?? switch (widget.activityId) {
      'story-recall' || 'life-story-reflection' => 'Storytelling & Recall',
        'number-sequence' => 'Number Sequence Recall',
        'object-location' => 'Object Location Test',
        _ => 'Card Matching',
      };

  @override
  void initState() {
    super.initState();
    _isStudying = !_isCardMatch;
    _storyIntro = widget.activityId == 'story-recall' ||
        widget.activityId == 'life-story-reflection';
  }

  @override
  void dispose() {
    _mismatchTimer?.cancel();
    super.dispose();
  }

  static List<_RecallQuestion> _questionsFor(String activityId) {
    if (activityId == 'story-recall' || activityId == 'life-story-reflection') {
      return const [
        _RecallQuestion(
          prompt: 'What color was Lina\'s basket?',
          options: ['Red', 'Blue', 'Green', 'Yellow'],
          correctIndex: 1,
        ),
        _RecallQuestion(
          prompt: 'What did Lina buy at the market?',
          options: ['Apples and tea', 'Oranges and bread', 'Rice and milk', 'Flowers and fruit'],
          correctIndex: 1,
        ),
        _RecallQuestion(
          prompt: 'Who did Lina meet near the fountain?',
          options: ['Her sister', 'Her neighbor Omar', 'A shopkeeper', 'Her friend Sara'],
          correctIndex: 1,
        ),
      ];
    }

    if (activityId == 'number-sequence') {
      return const [
        _RecallQuestion(
          studyContent: '2   7   4   9',
          prompt: 'Which number was third?',
          options: ['2', '7', '4', '9'],
          correctIndex: 2,
        ),
        _RecallQuestion(
          studyContent: '5   1   8   3',
          prompt: 'Which number was second?',
          options: ['5', '1', '8', '3'],
          correctIndex: 1,
        ),
        _RecallQuestion(
          studyContent: '6   2   9   4',
          prompt: 'Which number came last?',
          options: ['6', '2', '9', '4'],
          correctIndex: 3,
        ),
      ];
    }

    if (activityId == 'object-location') {
      return const [
        _RecallQuestion(
          studyObjects: [
            _LocationObject('Cup', Icons.local_cafe_rounded),
            _LocationObject('Key', Icons.key_rounded),
            _LocationObject('Leaf', Icons.eco_rounded),
            _LocationObject('Clock', Icons.access_time_rounded),
          ],
          prompt: 'Where was the key?',
          options: ['Top left', 'Top right', 'Bottom left', 'Bottom right'],
          correctIndex: 1,
        ),
        _RecallQuestion(
          studyObjects: [
            _LocationObject('Book', Icons.menu_book_rounded),
            _LocationObject('Apple', Icons.apple_rounded),
            _LocationObject('Bell', Icons.notifications_active_rounded),
            _LocationObject('Plant', Icons.local_florist_rounded),
          ],
          prompt: 'Where was the bell?',
          options: ['Top left', 'Top right', 'Bottom left', 'Bottom right'],
          correctIndex: 2,
        ),
        _RecallQuestion(
          studyObjects: [
            _LocationObject('Star', Icons.star_rounded),
            _LocationObject('Bag', Icons.backpack_rounded),
            _LocationObject('Phone', Icons.phone_iphone_rounded),
            _LocationObject('Flower', Icons.local_florist_rounded),
          ],
          prompt: 'Where was the phone?',
          options: ['Top left', 'Top right', 'Bottom left', 'Bottom right'],
          correctIndex: 2,
        ),
      ];
    }

    return const [
      _RecallQuestion(
        prompt: 'Which symbol matches the first card?',
        options: ['Sun', 'Leaf', 'Moon'],
        correctIndex: 0,
      ),
      _RecallQuestion(
        prompt: 'Which symbol matches the second card?',
        options: ['Moon', 'Leaf', 'Sun'],
        correctIndex: 1,
      ),
      _RecallQuestion(
        prompt: 'Which symbol matches the third card?',
        options: ['Sun', 'Moon', 'Leaf'],
        correctIndex: 2,
      ),
    ];
  }

  void _revealNextStep() {
    setState(() {
      _isStudying = false;
      _storyIntro = false;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null) return;

    final isCorrect = _selectedAnswer == _questions[_questionIndex].correctIndex;
    final totalCorrect = _correctAnswers + (isCorrect ? 1 : 0);
    if (_questionIndex == _questions.length - 1) {
      _finish(correctAnswers: totalCorrect, totalQuestions: _questions.length);
      return;
    }

    setState(() {
      _correctAnswers = totalCorrect;
      _questionIndex += 1;
      _selectedAnswer = null;
      _isStudying = _questions[_questionIndex].hasStudyMaterial;
    });
  }

  void _tapCard(int index) {
    if (_matchedCards.contains(index) || _openCards.contains(index) || _openCards.length == 2) {
      return;
    }

    setState(() => _openCards.add(index));
    if (_openCards.length < 2) return;

    final first = _openCards[0];
    final second = _openCards[1];
    if (_cards[first].pair == _cards[second].pair) {
      setState(() {
        _matchedCards.addAll([first, second]);
        _openCards.clear();
      });
      if (_matchedCards.length == _cards.length) {
        _finish(
          correctAnswers: (_cards.length ~/ 2 - _cardMistakes).clamp(0, _cards.length ~/ 2),
          totalQuestions: _cards.length ~/ 2,
        );
      }
      return;
    }

    _cardMistakes += 1;
    _mismatchTimer?.cancel();
    _mismatchTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) return;
      setState(_openCards.clear);
    });
  }

  void _finish({required int correctAnswers, required int totalQuestions}) {
    widget.onComplete(
      TherapyActivityResult(
        activityId: widget.activityId,
        activityTitle: _title,
        category: 'Games',
        correctAnswers: correctAnswers,
        totalQuestions: totalQuestions,
        elapsedSeconds: DateTime.now().difference(_startedAt).inSeconds,
        difficulty: widget.difficulty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TherapyPage(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              TherapyBackHeader(title: _title),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _isCardMatch
                      ? 'Pairs matched: ${_matchedCards.length ~/ 2} of ${_cards.length ~/ 2}'
                      : 'Step ${_questionIndex + 1} of ${_questions.length}',
                  style: const TextStyle(
                    color: TherapyColors.body,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _isCardMatch
                    ? _buildCardBoard()
                    : _storyIntro
                        ? _buildStoryIntro()
                        : _isStudying
                            ? _buildStudyStep(_questions[_questionIndex])
                            : _buildQuestion(_questions[_questionIndex]),
              ),
              if (!_isCardMatch && !_storyIntro && !_isStudying) ...[
                const SizedBox(height: 12),
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

  Widget _buildStoryIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TherapyCard(
          color: const Color(0xFFE7F7F1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.menu_book_rounded, color: TherapyColors.tealDark, size: 28),
              const SizedBox(height: 12),
              const Text(
                _story,
                style: TextStyle(color: TherapyColors.navy, fontSize: 16, height: 1.55),
              ),
            ],
          ),
        ),
        const Spacer(),
        TherapyPrimaryButton(label: 'Begin questions', onPressed: _revealNextStep),
      ],
    );
  }

  Widget _buildStudyStep(_RecallQuestion question) {
    return Column(
      children: [
        Expanded(
          child: question.studyObjects != null
              ? _buildLocationBoard(question.studyObjects!)
              : Center(
                  child: TherapyCard(
                    color: const Color(0xFFE7F7F1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.numbers_rounded, color: TherapyColors.tealDark, size: 32),
                        const SizedBox(height: 12),
                        Text(
                          question.studyContent ?? '',
                          style: const TextStyle(
                            color: TherapyColors.navy,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 14),
        TherapyPrimaryButton(label: 'Ready', onPressed: _revealNextStep),
      ],
    );
  }

  Widget _buildLocationBoard(List<_LocationObject> objects) {
    return GridView.builder(
      itemCount: objects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final object = objects[index];
        return TherapyCard(
          color: const Color(0xFFE7F7F1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(object.icon, color: TherapyColors.tealDark, size: 32),
              const SizedBox(height: 6),
              Text(object.label, style: const TextStyle(color: TherapyColors.navy, fontWeight: FontWeight.w700)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestion(_RecallQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Text(
          question.prompt,
          style: const TextStyle(color: TherapyColors.navy, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        for (var index = 0; index < question.options.length; index++) ...[
          _AnswerOption(
            label: question.options[index],
            selected: _selectedAnswer == index,
            onTap: () => setState(() => _selectedAnswer = index),
          ),
          if (index != question.options.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildCardBoard() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final isVisible = _matchedCards.contains(index) || _openCards.contains(index);
        final card = _cards[index];
        return Material(
          color: isVisible ? const Color(0xFFE7F7F1) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => _tapCard(index),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD8E5EA)),
              ),
              child: Center(
                child: isVisible
                    ? Icon(card.icon, color: TherapyColors.tealDark, size: 34)
                    : const Icon(Icons.style_rounded, color: TherapyColors.primary, size: 32),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({required this.label, required this.selected, required this.onTap});

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
          constraints: const BoxConstraints(minHeight: 54),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? TherapyColors.tealDark : const Color(0xFFD8E5EA)),
          ),
          child: Text(label, style: const TextStyle(color: TherapyColors.navy, fontSize: 15, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _RecallQuestion {
  const _RecallQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.studyContent,
    this.studyObjects,
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? studyContent;
  final List<_LocationObject>? studyObjects;

  bool get hasStudyMaterial => studyContent != null || studyObjects != null;
}

class _LocationObject {
  const _LocationObject(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _MatchCard {
  const _MatchCard({required this.pair, required this.icon});

  final String pair;
  final IconData icon;
}

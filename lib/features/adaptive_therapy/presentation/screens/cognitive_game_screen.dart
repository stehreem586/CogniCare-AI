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
  static const _imageUrls = {
    'cat':
        'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=400&q=85',
    'dog':
        'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=400&q=85',
    'rabbit':
        'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?auto=format&fit=crop&w=400&q=85',
    'cup':
        'https://images.unsplash.com/photo-1514228742587-6b1558fcca3d?auto=format&fit=crop&w=400&q=80',
    'key':
        'https://images.unsplash.com/photo-1553484771-371a605b060b?auto=format&fit=crop&w=400&q=80',
    'clock':
        'https://images.unsplash.com/photo-1501139083538-0139583c060f?auto=format&fit=crop&w=400&q=80',
    'book':
        'https://images.unsplash.com/photo-1544947950-fa07a98d237f?auto=format&fit=crop&w=400&q=80',
    'apple':
        'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=400&q=80',
    'bell':
        'https://images.unsplash.com/photo-1570993492881-25240ce854f3?auto=format&fit=crop&w=400&q=80',
    'plant':
        'https://images.unsplash.com/photo-1485955900006-10f4d324d411?auto=format&fit=crop&w=400&q=80',
    'star':
        'https://images.unsplash.com/photo-1534791547706-9c7f5a3e6f4f?auto=format&fit=crop&w=400&q=80',
    'bag':
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=400&q=80',
    'phone':
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=400&q=80',
    'flower':
        'https://images.unsplash.com/photo-1490750967868-88aa4486c946?auto=format&fit=crop&w=400&q=80',
  };

  static const _story =
      'On Tuesday morning, Lina walked to the market with a blue basket. '
      'She bought oranges and bread, then met her neighbor Omar near the fountain. '
      'Before going home, Lina left the bread with her sister.';

  static const _cards = [
    _MatchCard(pair: 'cat'),
    _MatchCard(pair: 'dog'),
    _MatchCard(pair: 'rabbit'),
    _MatchCard(pair: 'rabbit'),
    _MatchCard(pair: 'cat'),
    _MatchCard(pair: 'dog'),
  ];

  late final DateTime _startedAt = DateTime.now();
  late final List<_RecallQuestion> _questions = _questionsFor(
    widget.activityId,
  );
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
      widget.activityId == 'card-matching' ||
      widget.activityId == 'memory-match';

  String get _title =>
      widget.activityTitle ??
      switch (widget.activityId) {
        'story-recall' || 'life-story-reflection' => 'Storytelling & Recall',
        'number-sequence' => 'Number Sequence Recall',
        'object-location' => 'Object Location Test',
        _ => 'Card Matching',
      };

  @override
  void initState() {
    super.initState();
    _isStudying = !_isCardMatch;
    _storyIntro =
        widget.activityId == 'story-recall' ||
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
          options: [
            'Apples and tea',
            'Oranges and bread',
            'Rice and milk',
            'Flowers and fruit',
          ],
          correctIndex: 1,
        ),
        _RecallQuestion(
          prompt: 'Who did Lina meet near the fountain?',
          options: [
            'Her sister',
            'Her neighbor Omar',
            'A shopkeeper',
            'Her friend Sara',
          ],
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
            _LocationObject('Cup', 'cup'),
            _LocationObject('Key', 'key'),
            _LocationObject('Leaf', 'leaf'),
            _LocationObject('Clock', 'clock'),
          ],
          prompt: 'Where was the key?',
          options: ['Top left', 'Top right', 'Bottom left', 'Bottom right'],
          correctIndex: 1,
        ),
        _RecallQuestion(
          studyObjects: [
            _LocationObject('Book', 'book'),
            _LocationObject('Apple', 'apple'),
            _LocationObject('Bell', 'bell'),
            _LocationObject('Plant', 'plant'),
          ],
          prompt: 'Where was the bell?',
          options: ['Top left', 'Top right', 'Bottom left', 'Bottom right'],
          correctIndex: 2,
        ),
        _RecallQuestion(
          studyObjects: [
            _LocationObject('Star', 'star'),
            _LocationObject('Bag', 'bag'),
            _LocationObject('Phone', 'phone'),
            _LocationObject('Flower', 'flower'),
          ],
          prompt: 'Where was the phone?',
          options: ['Top left', 'Top right', 'Bottom left', 'Bottom right'],
          correctIndex: 2,
        ),
      ];
    }

    return const [
      _RecallQuestion(
        prompt: 'Which animal matches the first card?',
        options: ['Cat', 'Dog', 'Rabbit'],
        correctIndex: 0,
      ),
      _RecallQuestion(
        prompt: 'Which animal matches the second card?',
        options: ['Rabbit', 'Dog', 'Cat'],
        correctIndex: 1,
      ),
      _RecallQuestion(
        prompt: 'Which animal matches the third card?',
        options: ['Cat', 'Rabbit', 'Dog'],
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

    final isCorrect =
        _selectedAnswer == _questions[_questionIndex].correctIndex;
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
    if (_matchedCards.contains(index) ||
        _openCards.contains(index) ||
        _openCards.length == 2) {
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
          correctAnswers: (_cards.length ~/ 2 - _cardMistakes).clamp(
            0,
            _cards.length ~/ 2,
          ),
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
                  label: _questionIndex == _questions.length - 1
                      ? 'Finish'
                      : 'Continue',
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
              const Icon(
                Icons.menu_book_rounded,
                color: TherapyColors.tealDark,
                size: 28,
              ),
              const SizedBox(height: 12),
              const Text(
                _story,
                style: TextStyle(
                  color: TherapyColors.navy,
                  fontSize: 16,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        TherapyPrimaryButton(
          label: 'Begin questions',
          onPressed: _revealNextStep,
        ),
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
                        const Icon(
                          Icons.numbers_rounded,
                          color: TherapyColors.tealDark,
                          size: 32,
                        ),
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
              _GameImage(
                imageUrl: _imageUrls[object.imageKey]!,
                width: 76,
                height: 76,
              ),
              const SizedBox(height: 6),
              Text(
                object.label,
                style: const TextStyle(
                  color: TherapyColors.navy,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
          style: const TextStyle(
            color: TherapyColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
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
        final isVisible =
            _matchedCards.contains(index) || _openCards.contains(index);
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
                    ? _GameImage(
                        imageUrl: _imageUrls[card.pair]!,
                        width: 88,
                        height: 88,
                      )
                    : const _HiddenGameImage(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
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
          constraints: const BoxConstraints(minHeight: 54),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? TherapyColors.tealDark
                  : const Color(0xFFD8E5EA),
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
  const _LocationObject(this.label, this.imageKey);

  final String label;
  final String imageKey;
}

class _MatchCard {
  const _MatchCard({required this.pair});

  final String pair;
}

class _GameImage extends StatelessWidget {
  const _GameImage({
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  final String imageUrl;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: const Color(0xFFDCEEF4),
        ),
      ),
    );
  }
}

class _HiddenGameImage extends StatelessWidget {
  const _HiddenGameImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F7F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          '?',
          style: TextStyle(
            color: TherapyColors.primary,
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

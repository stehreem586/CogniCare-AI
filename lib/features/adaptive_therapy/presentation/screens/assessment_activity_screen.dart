import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/models/therapy_models.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';

class AssessmentActivityScreen extends StatefulWidget {
  const AssessmentActivityScreen({
    super.key,
    required this.definition,
    required this.activityNumber,
    required this.totalActivities,
    required this.onComplete,
  });

  final AssessmentActivityDefinition definition;
  final int activityNumber;
  final int totalActivities;
  final ValueChanged<AssessmentActivityScore> onComplete;

  @override
  State<AssessmentActivityScreen> createState() => _AssessmentActivityScreenState();
}

class _AssessmentActivityScreenState extends State<AssessmentActivityScreen> {
  static const _animalImageUrls = {
    'cat': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=500&q=88',
    'dog': 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=500&q=88',
    'rabbit': 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?auto=format&fit=crop&w=500&q=88',
  };

  late final List<_Question> _questions;
  Timer? _timer;
  int _studySeconds = 0;
  int _questionIndex = 0;
  int _correct = 0;
  int? _selected;
  bool _isStudying = true;
  bool _isCardGame = false;
  final Set<int> _matchedCards = {};
  final List<int> _openCards = [];
  int _cardMistakes = 0;

  @override
  void initState() {
    super.initState();
    _questions = _questionsFor(widget.definition.kind);
    _isCardGame = widget.definition.kind == AssessmentActivityKind.cardMatching;
    _studySeconds = widget.definition.kind == AssessmentActivityKind.delayedRecall ? 5 : 0;
    if (_studySeconds > 0) _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_studySeconds <= 1) {
        _timer?.cancel();
        setState(() {
          _studySeconds = 0;
          _isStudying = false;
        });
      } else {
        setState(() => _studySeconds--);
      }
    });
  }

  static List<_Question> _questionsFor(AssessmentActivityKind kind) {
    switch (kind) {
      case AssessmentActivityKind.story:
        return const [
          _Question('What colour was Lina\'s basket?', ['Red', 'Blue', 'Green', 'Yellow'], 1),
          _Question('What did Lina buy?', ['Tea and rice', 'Oranges and bread', 'Milk and apples', 'Flowers'], 1),
          _Question('Who did Lina meet?', ['Omar', 'Sara', 'A shopkeeper', 'Her sister'], 0),
        ];
      case AssessmentActivityKind.numericalSequence:
        return const [
          _Question('In 2, 7, 4, 9, which number was third?', ['2', '7', '4', '9'], 2),
          _Question('In 5, 1, 8, 3, which number was second?', ['5', '1', '8', '3'], 1),
          _Question('In 6, 2, 9, 4, which number was last?', ['6', '2', '9', '4'], 3),
        ];
      case AssessmentActivityKind.objectLocation:
        return const [
          _Question('Where was the key?', ['Top left', 'Top right', 'Bottom left', 'Bottom right'], 1),
          _Question('Where was the bell?', ['Top left', 'Top right', 'Bottom left', 'Bottom right'], 2),
          _Question('Where was the phone?', ['Top left', 'Top right', 'Bottom left', 'Bottom right'], 2),
        ];
      case AssessmentActivityKind.delayedRecall:
        return const [
          _Question('Which word was on the list?', ['Garden', 'Window', 'River', 'Orange'], 3),
          _Question('Which word was on the list?', ['Chair', 'Garden', 'Pencil', 'Cloud'], 1),
          _Question('Which word was on the list?', ['River', 'Orange', 'Table', 'Window'], 0),
        ];
      case AssessmentActivityKind.patternRecall:
        return const [
          _Question('Which pattern did you see?', ['Blue, red, blue', 'Red, red, blue', 'Green, blue, green'], 0),
          _Question('Which pattern did you see?', ['Circle, square, circle', 'Square, square, circle', 'Circle, triangle, square'], 2),
          _Question('Which pattern did you see?', ['Star, heart, star', 'Heart, star, heart', 'Star, star, heart'], 1),
        ];
      case AssessmentActivityKind.everydayObjects:
        return const [
          _Question('Which object did you see?', ['Cup', 'Key', 'Spoon', 'Phone'], 0),
          _Question('Which object did you see?', ['Book', 'Toothbrush', 'Clock', 'Glasses'], 2),
          _Question('Which object did you see?', ['Wallet', 'Plate', 'Lamp', 'Bag'], 3),
        ];
      case AssessmentActivityKind.cardMatching:
        return const [];
    }
  }

  void _beginQuestions() {
    if (_studySeconds > 0) return;
    setState(() => _isStudying = false);
  }

  void _submitAnswer() {
    if (_selected == null) return;
    final isCorrect = _selected == _questions[_questionIndex].correctIndex;
    final updatedCorrect = _correct + (isCorrect ? 1 : 0);
    if (_questionIndex == _questions.length - 1) {
      _finish(updatedCorrect, _questions.length);
      return;
    }
    setState(() {
      _correct = updatedCorrect;
      _questionIndex++;
      _selected = null;
    });
  }

  void _tapCard(int index) {
    if (_matchedCards.contains(index) || _openCards.contains(index) || _openCards.length == 2) return;
    setState(() => _openCards.add(index));
    if (_openCards.length < 2) return;
    final cards = const ['sun', 'leaf', 'moon', 'moon', 'sun', 'leaf'];
    if (cards[_openCards[0]] == cards[_openCards[1]]) {
      setState(() {
        _matchedCards.addAll(_openCards);
        _openCards.clear();
      });
      if (_matchedCards.length == cards.length) {
        _finish((cards.length ~/ 2 - _cardMistakes).clamp(0, cards.length ~/ 2), cards.length ~/ 2);
      }
    } else {
      _cardMistakes++;
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 700), () {
        if (mounted) setState(_openCards.clear);
      });
    }
  }

  void _finish(int correct, int total) {
    widget.onComplete(
      AssessmentActivityScore(
        activityId: widget.definition.id,
        activityTitle: widget.definition.title,
        correctAnswers: correct,
        totalQuestions: total,
        score: total == 0 ? 0 : ((correct / total) * 100).round(),
        completedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TherapyPage(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            children: [
              TherapyBackHeader(title: widget.definition.title),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Activity ${widget.activityNumber} of ${widget.totalActivities}',
                  style: const TextStyle(color: TherapyColors.tealDark, fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.definition.instruction,
                  style: const TextStyle(color: TherapyColors.body, fontSize: 20, height: 1.35),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isCardGame) return _buildCards();
    if (_isStudying) return _buildStudy();
    final question = _questions[_questionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Question ${_questionIndex + 1} of ${_questions.length}', style: const TextStyle(color: TherapyColors.navy, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        Text(question.prompt, style: const TextStyle(color: TherapyColors.navy, fontSize: 27, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        ...List.generate(question.options.length, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _AnswerButton(
            label: question.options[index],
            selected: _selected == index,
            onTap: () => setState(() => _selected = index),
          ),
        )),
        const Spacer(),
        _LargeButton(label: _questionIndex == _questions.length - 1 ? 'Finish activity' : 'Next question', onPressed: _selected == null ? () {} : _submitAnswer),
      ],
    );
  }

  Widget _buildStudy() {
    final isDelayed = widget.definition.kind == AssessmentActivityKind.delayedRecall;
    if (widget.definition.kind == AssessmentActivityKind.objectLocation) {
      return _buildObjectGrid();
    }
    if (widget.definition.kind == AssessmentActivityKind.everydayObjects) {
      return _buildVisualStudyRow(const ['cup', 'clock', 'book', 'bag']);
    }
    if (widget.definition.kind == AssessmentActivityKind.patternRecall) {
      return _buildPatternStudy();
    }
    if (widget.definition.kind == AssessmentActivityKind.story) {
      return _buildStoryStudy();
    }
    if (widget.definition.kind == AssessmentActivityKind.delayedRecall) {
      return _buildDelayedStudy();
    }
    final text = switch (widget.definition.kind) {
      AssessmentActivityKind.story => 'Lina carried a blue basket to the market. She bought oranges and bread, then met Omar near the fountain.',
      AssessmentActivityKind.numericalSequence => '2   7   4   9',
      AssessmentActivityKind.objectLocation => 'Cup: top left\nKey: top right\nLeaf: bottom left\nClock: bottom right',
      AssessmentActivityKind.patternRecall => 'Blue   Red   Blue\nCircle   Triangle   Square\nStar   Heart   Star',
      AssessmentActivityKind.everydayObjects => 'Cup   Clock   Book   Bag',
      AssessmentActivityKind.delayedRecall => 'Orange   Garden   River',
      AssessmentActivityKind.cardMatching => '',
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TherapyCard(
          color: const Color(0xFFE7F7F1),
          child: Text(text, style: const TextStyle(color: TherapyColors.navy, fontSize: 24, height: 1.5, fontWeight: FontWeight.w700)),
        ),
        const Spacer(),
        if (isDelayed) Center(child: Text('Remember for $_studySeconds seconds', style: const TextStyle(color: TherapyColors.tealDark, fontSize: 22, fontWeight: FontWeight.w800))),
        const SizedBox(height: 16),
        _LargeButton(label: _studySeconds > 0 ? 'Please remember' : 'Begin questions', onPressed: _studySeconds > 0 ? () {} : _beginQuestions),
      ],
    );
  }

  Widget _buildStoryStudy() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TherapyCard(
            color: const Color(0xFFE7F7F1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _ObjectVisual(label: 'basket', size: 78),
                    _ObjectVisual(label: 'orange', size: 78),
                    _ObjectVisual(label: 'bread', size: 78),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Lina carried a blue basket to the market. She bought oranges and bread, then met Omar near the fountain.', style: TextStyle(color: TherapyColors.navy, fontSize: 22, height: 1.45, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const Spacer(),
          _LargeButton(label: 'Begin questions', onPressed: _beginQuestions),
        ],
      );

  Widget _buildDelayedStudy() => Column(
        children: [
          TherapyCard(
            color: const Color(0xFFE7F7F1),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _ObjectVisual(label: 'orange', size: 86),
                    _ObjectVisual(label: 'garden', size: 86),
                    _ObjectVisual(label: 'river', size: 86),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Orange     Garden     River', style: TextStyle(color: TherapyColors.navy, fontSize: 22, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          const Spacer(),
          Center(child: Text('Remember for $_studySeconds seconds', style: const TextStyle(color: TherapyColors.tealDark, fontSize: 22, fontWeight: FontWeight.w800))),
          const SizedBox(height: 16),
          _LargeButton(label: _studySeconds > 0 ? 'Please remember' : 'Begin questions', onPressed: _studySeconds > 0 ? () {} : _beginQuestions),
        ],
      );

  Widget _buildObjectGrid() => Column(
        children: [
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              children: const [
                _VisualStudyCard(label: 'cup', position: 'Top left'),
                _VisualStudyCard(label: 'key', position: 'Top right'),
                _VisualStudyCard(label: 'leaf', position: 'Bottom left'),
                _VisualStudyCard(label: 'clock', position: 'Bottom right'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _LargeButton(label: 'Begin questions', onPressed: _beginQuestions),
        ],
      );

  Widget _buildVisualStudyRow(List<String> labels) => Column(
        children: [
          TherapyCard(
            color: const Color(0xFFE7F7F1),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 18,
              runSpacing: 18,
              children: labels.map((label) => _ObjectVisual(label: label, size: 82)).toList(),
            ),
          ),
          const Spacer(),
          _LargeButton(label: 'Begin questions', onPressed: _beginQuestions),
        ],
      );

  Widget _buildPatternStudy() => Column(
        children: [
          TherapyCard(
            color: const Color(0xFFE7F7F1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _PatternTile(color: Color(0xFF3B9AE1), shape: Icons.circle),
                _PatternTile(color: Color(0xFFE56B9A), shape: Icons.square_rounded),
                _PatternTile(color: Color(0xFF3B9AE1), shape: Icons.circle),
              ],
            ),
          ),
          const Spacer(),
          _LargeButton(label: 'Begin questions', onPressed: _beginQuestions),
        ],
      );

  Widget _buildCards() {
    const cards = ['cat', 'dog', 'rabbit', 'rabbit', 'cat', 'dog'];
    return Column(
      children: [
        Text(
          'Pairs found: ${_matchedCards.length ~/ 2} of 3',
          style: const TextStyle(
            color: TherapyColors.navy,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: GridView.builder(
            itemCount: cards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 14, crossAxisSpacing: 14),
            itemBuilder: (context, index) {
              final visible = _matchedCards.contains(index) || _openCards.contains(index);
              return InkWell(
                onTap: () => _tapCard(index),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(color: visible ? const Color(0xFFE7F7F1) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: TherapyColors.primary)),
                  padding: const EdgeInsets.all(7),
                  child: visible
                      ? _AnimalImage(url: _animalImageUrls[cards[index]]!)
                      : const _CardBack(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

  class _AnimalImage extends StatelessWidget {
    const _AnimalImage({required this.url});

    final String url;

    @override
    Widget build(BuildContext context) => ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFBDEBFF), Color(0xFFE7F7F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        );
  }

  class _CardBack extends StatelessWidget {
    const _CardBack();

    @override
    Widget build(BuildContext context) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0066BD), Color(0xFF39A9DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Center(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 2),
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        );
  }

class _Question {
  const _Question(this.prompt, this.options, this.correctIndex);
  final String prompt;
  final List<String> options;
  final int correctIndex;
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? const Color(0xFFE7F7F1) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: selected ? TherapyColors.tealDark : TherapyColors.primary, width: 2)),
            child: Text(label, style: const TextStyle(color: TherapyColors.navy, fontSize: 21, fontWeight: FontWeight.w700)),
          ),
        ),
      );
}

class _LargeButton extends StatelessWidget {
  const _LargeButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 64,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(backgroundColor: TherapyColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: Text(label, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800)),
        ),
      );
}

class _VisualStudyCard extends StatelessWidget {
  const _VisualStudyCard({required this.label, required this.position});
  final String label;
  final String position;

  @override
  Widget build(BuildContext context) => TherapyCard(
        color: const Color(0xFFE7F7F1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ObjectVisual(label: label, size: 64),
            const SizedBox(height: 5),
            Text(position, style: const TextStyle(color: TherapyColors.navy, fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _PatternTile extends StatelessWidget {
  const _PatternTile({required this.color, required this.shape});
  final Color color;
  final IconData shape;

  @override
  Widget build(BuildContext context) => Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
        child: Icon(shape, color: color, size: 42),
      );
}

class _ObjectVisual extends StatelessWidget {
  const _ObjectVisual({required this.label, required this.size});
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _ObjectPainter(label)),
      );
}

class _ObjectPainter extends CustomPainter {
  const _ObjectPainter(this.label);
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.shortestSide / 80;
    final fill = Paint()..color = switch (label) {
          'sun' => const Color(0xFFF0C75E),
          'leaf' => const Color(0xFF3FA36A),
          'moon' => const Color(0xFF8C9BE8),
          'apple' => const Color(0xFFE56B6F),
          'orange' => const Color(0xFFF0A100),
          'cup' => const Color(0xFF5B9DEF),
          'clock' => const Color(0xFF9B6BDB),
          'book' => const Color(0xFFE56B9A),
          'bag' => const Color(0xFF9B7555),
          'key' => const Color(0xFFF0A100),
          'basket' => const Color(0xFF5B9DEF),
          'bread' => const Color(0xFFD9A441),
          'garden' => const Color(0xFF3FA36A),
          'river' => const Color(0xFF5B9DEF),
          _ => TherapyColors.primary,
        };
    if (label == 'sun' || label == 'moon' || label == 'orange' || label == 'apple' || label == 'clock') {
      canvas.drawCircle(center, 25 * scale, fill);
    } else if (label == 'leaf') {
      canvas.drawOval(Rect.fromCenter(center: center, width: 34 * scale, height: 58 * scale), fill);
      canvas.drawLine(center.translate(-15 * scale, 17 * scale), center.translate(16 * scale, -17 * scale), Paint()..color = Colors.white..strokeWidth = 3 * scale);
    } else if (label == 'apple') {
      canvas.drawOval(Rect.fromCenter(center: center.translate(13 * scale, -24 * scale), width: 18 * scale, height: 10 * scale), Paint()..color = const Color(0xFF3FA36A));
    } else if (label == 'clock') {
      final hands = Paint()..color = Colors.white..strokeWidth = 4 * scale..strokeCap = StrokeCap.round;
      canvas.drawLine(center, center.translate(0, -16 * scale), hands);
      canvas.drawLine(center, center.translate(13 * scale, 9 * scale), hands);
    } else if (label == 'cup') {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 40 * scale, height: 34 * scale), Radius.circular(7 * scale)), fill);
      canvas.drawArc(Rect.fromCenter(center: center.translate(19 * scale, 0), width: 22 * scale, height: 22 * scale), -1.5, 3, false, Paint()..color = fill.color..style = PaintingStyle.stroke..strokeWidth = 6 * scale);
    } else if (label == 'book') {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 48 * scale, height: 38 * scale), Radius.circular(4 * scale)), fill);
      canvas.drawLine(center.translate(0, -18 * scale), center.translate(0, 18 * scale), Paint()..color = Colors.white..strokeWidth = 3 * scale);
    } else if (label == 'bag') {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(0, 7 * scale), width: 44 * scale, height: 40 * scale), Radius.circular(7 * scale)), fill);
      canvas.drawArc(Rect.fromCenter(center: center.translate(0, -14 * scale), width: 22 * scale, height: 24 * scale), 3.2, 3, false, Paint()..color = fill.color..style = PaintingStyle.stroke..strokeWidth = 5 * scale);
    } else if (label == 'key') {
      final keyPaint = Paint()..color = fill.color..strokeWidth = 8 * scale..strokeCap = StrokeCap.round;
      canvas.drawLine(center.translate(-18 * scale, 9 * scale), center.translate(17 * scale, -9 * scale), keyPaint);
      canvas.drawCircle(center.translate(-20 * scale, 11 * scale), 10 * scale, keyPaint..style = PaintingStyle.stroke);
    } else if (label == 'basket') {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center.translate(0, 8 * scale), width: 48 * scale, height: 34 * scale), Radius.circular(6 * scale)), fill);
      canvas.drawArc(Rect.fromCenter(center: center.translate(0, -8 * scale), width: 34 * scale, height: 34 * scale), 3.2, 3, false, Paint()..color = fill.color..style = PaintingStyle.stroke..strokeWidth = 5 * scale);
    } else if (label == 'bread') {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: 52 * scale, height: 30 * scale), Radius.circular(15 * scale)), fill);
      canvas.drawLine(center.translate(-10 * scale, -8 * scale), center.translate(-10 * scale, 8 * scale), Paint()..color = Colors.white..strokeWidth = 3 * scale);
      canvas.drawLine(center.translate(4 * scale, -8 * scale), center.translate(4 * scale, 8 * scale), Paint()..color = Colors.white..strokeWidth = 3 * scale);
    } else if (label == 'garden' || label == 'river') {
      final landscape = Paint()..color = label == 'river' ? const Color(0xFF5B9DEF) : const Color(0xFF3FA36A);
      canvas.drawOval(Rect.fromCenter(center: center.translate(0, 14 * scale), width: 58 * scale, height: 22 * scale), landscape);
      canvas.drawRect(Rect.fromCenter(center: center.translate(0, 25 * scale), width: 54 * scale, height: 10 * scale), landscape);
    }
  }

  @override
  bool shouldRepaint(covariant _ObjectPainter oldDelegate) => oldDelegate.label != label;
}

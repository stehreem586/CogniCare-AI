import 'package:flutter/material.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';
import '../widgets/therapy_illustrations.dart';

class CognitiveGameScreen extends StatefulWidget {
  const CognitiveGameScreen({super.key, required this.onNext});

  final VoidCallback onNext;

  @override
  State<CognitiveGameScreen> createState() => _CognitiveGameScreenState();
}

class _CognitiveGameScreenState extends State<CognitiveGameScreen> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return TherapyPage(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              const TherapyBackHeader(title: 'Cognitive Games'),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Find the Missing Piece',
                      style: TextStyle(
                        color: TherapyColors.navy,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Look at the picture and choose the missing piece.',
                      style: TextStyle(color: TherapyColors.body, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const SizedBox(
                height: 210,
                width: double.infinity,
                child: MountainLakeScene(showMissingPiece: true, borderRadius: 18),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < 4; i++)
                    MiniPuzzlePiece(
                      label: String.fromCharCode(65 + i),
                      variant: i,
                      selected: _selected == i,
                      onTap: () => setState(() => _selected = i),
                    ),
                ],
              ),
              const Spacer(),
              TherapyPrimaryButton(
                label: 'Next',
                onPressed: widget.onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

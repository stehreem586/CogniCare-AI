import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';
import '../widgets/therapy_illustrations.dart';

class MemoryExerciseScreen extends StatefulWidget {
  const MemoryExerciseScreen({super.key, required this.onReady});

  final VoidCallback onReady;

  @override
  State<MemoryExerciseScreen> createState() => _MemoryExerciseScreenState();
}

class _MemoryExerciseScreenState extends State<MemoryExerciseScreen> {
  int _seconds = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds == 0) {
        timer.cancel();
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

  @override
  Widget build(BuildContext context) {
    return TherapyPage(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              const TherapyBackHeader(title: 'Memory Exercises'),
              TherapyCard(
                color: const Color(0xFFE7F7F1),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.spa_rounded, color: TherapyColors.tealDark),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Remember the Picture',
                            style: TextStyle(
                              color: TherapyColors.navy,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Look at the image for 10 seconds. Then try to answer the questions.',
                            style: TextStyle(color: TherapyColors.body, fontSize: 13, height: 1.35),
                          ),
                        ],
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
              const SizedBox(height: 20),
              TherapyPrimaryButton(label: "I'm Ready", onPressed: widget.onReady),
            ],
          ),
        ),
      ),
    );
  }
}

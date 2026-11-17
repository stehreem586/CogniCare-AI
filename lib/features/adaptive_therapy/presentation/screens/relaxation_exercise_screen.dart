import 'package:flutter/material.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';
import '../widgets/therapy_illustrations.dart';

class RelaxationExerciseScreen extends StatefulWidget {
  const RelaxationExerciseScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<RelaxationExerciseScreen> createState() => _RelaxationExerciseScreenState();
}

class _RelaxationExerciseScreenState extends State<RelaxationExerciseScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePause() {
    setState(() {
      _paused = !_paused;
      if (_paused) {
        _controller.stop();
      } else {
        _controller.repeat(reverse: true);
      }
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
              const TherapyBackHeader(title: 'Relaxation Exercise'),
              const SizedBox(height: 8),
              SizedBox(
                height: 168,
                width: double.infinity,
                child: Stack(
                  children: [
                    const Positioned.fill(child: MountainLakeScene()),
                    const Positioned(
                      right: 12,
                      top: 12,
                      child: TherapyBadge(label: '5 min'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Deep Breathing',
                style: TextStyle(
                  color: TherapyColors.navy,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Take slow, deep breaths. This helps calm your mind and reduce stress.',
                textAlign: TextAlign.center,
                style: TextStyle(color: TherapyColors.body, fontSize: 14.5, height: 1.4),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  final t = Curves.easeInOut.transform(_controller.value);
                  final scale = 0.86 + (t * 0.18);
                  final inhaling = _controller.status == AnimationStatus.forward ||
                      _controller.status == AnimationStatus.dismissed;
                  return Column(
                    children: [
                      Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 188,
                          height: 188,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                const Color(0xFFBDEBFF).withValues(alpha: 0.2),
                                const Color(0xFF7ED6F5).withValues(alpha: 0.18),
                                const Color(0xFF3BB7E6).withValues(alpha: 0.12),
                              ],
                            ),
                            border: Border.all(color: const Color(0xFF7ED6F5), width: 10),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  inhaling ? 'Breathe in' : 'Breathe out',
                                  style: const TextStyle(
                                    color: TherapyColors.navy,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  inhaling ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: TherapyColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              TherapyPrimaryButton(
                label: _paused ? 'Resume' : 'Pause',
                icon: _paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                onPressed: _togglePause,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: widget.onComplete,
                child: const Text(
                  'Complete Exercise',
                  style: TextStyle(
                    color: TherapyColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

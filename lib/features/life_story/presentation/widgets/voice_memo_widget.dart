import 'dart:async';
import 'package:flutter/material.dart';

class VoiceMemoWidget extends StatefulWidget {
  final int initialDurationSeconds;
  final ValueChanged<int>? onDurationChanged;

  const VoiceMemoWidget({
    super.key,
    this.initialDurationSeconds = 24,
    this.onDurationChanged,
  });

  @override
  State<VoiceMemoWidget> createState() => _VoiceMemoWidgetState();
}

class _VoiceMemoWidgetState extends State<VoiceMemoWidget> {
  bool _isPlayingOrRecording = false;
  late int _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seconds = widget.initialDurationSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleAudio() {
    setState(() {
      _isPlayingOrRecording = !_isPlayingOrRecording;
    });

    if (_isPlayingOrRecording) {
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        setState(() {
          _seconds++;
          widget.onDurationChanged?.call(_seconds);
        });
      });
    } else {
      _timer?.cancel();
    }
  }

  String _formatDuration(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          // Green Circular Mic / Play Button
          GestureDetector(
            onTap: _toggleAudio,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFF2EAA55),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x332EAA55),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  _isPlayingOrRecording
                      ? Icons.pause_rounded
                      : Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Audio Waveform Visualization
          Expanded(
            child: SizedBox(
              height: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _buildWaveformBars(),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Duration Text
          Text(
            _formatDuration(_seconds),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWaveformBars() {
    // Rhythmic bar heights matching the design
    final heights = [
      8.0,
      14.0,
      22.0,
      16.0,
      26.0,
      18.0,
      10.0,
      24.0,
      12.0,
      20.0,
      14.0,
      8.0,
      18.0,
      24.0,
      16.0,
      10.0,
      22.0,
      12.0,
      6.0,
    ];

    return heights.asMap().entries.map((entry) {
      final h = entry.value;
      final isHighlighted = entry.key < 9;

      return Container(
        width: 3.2,
        height: h,
        decoration: BoxDecoration(
          color: isHighlighted
              ? const Color(0xFF2B6CB0)
              : const Color(0xFFCBD5E1),
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }).toList();
  }
}

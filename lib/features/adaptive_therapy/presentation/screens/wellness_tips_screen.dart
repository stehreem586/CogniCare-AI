import 'package:flutter/material.dart';
import '../../data/mock_therapy_data.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';

class WellnessTipsScreen extends StatefulWidget {
  const WellnessTipsScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  State<WellnessTipsScreen> createState() => _WellnessTipsScreenState();
}

class _WellnessTipsScreenState extends State<WellnessTipsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final tips = MockTherapyCatalog.tips
        .where((t) => _filter == 'All' || t.category == _filter)
        .toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (widget.showBack)
            const TherapyBackHeader(title: 'Wellness Tips')
          else
            const Padding(
              padding: EdgeInsets.fromLTRB(4, 12, 4, 16),
              child: Text(
                'Wellness Tips',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TherapyColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          TherapyCard(
            color: TherapyColors.cardYellow,
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.lightbulb_rounded, color: Color(0xFFF0A100), size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Small steps make\na big difference!',
                        style: TextStyle(
                          color: TherapyColors.navy,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Here are some tips to help you feel better today.',
                        style: TextStyle(color: TherapyColors.body, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final chip in ['All', 'Mood', 'Sleep', 'Health']) ...[
                _FilterChip(
                  label: chip,
                  selected: _filter == chip,
                  onTap: () => setState(() => _filter = chip),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 16),
          for (final tip in tips) ...[
            TherapyCard(
              child: Row(
                children: [
                  _TipIcon(kind: tip.iconKind),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip.title,
                          style: const TextStyle(
                            color: TherapyColors.navy,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip.body,
                          style: const TextStyle(color: TherapyColors.body, fontSize: 13, height: 1.35),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: TherapyColors.muted),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? TherapyColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? TherapyColors.primary : const Color(0xFFD7E4F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : TherapyColors.navy,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TipIcon extends StatelessWidget {
  const _TipIcon({required this.kind});

  final TipIconKind kind;

  @override
  Widget build(BuildContext context) {
    final spec = switch (kind) {
      TipIconKind.water => (TherapyColors.cardBlue, const Color(0xFF3B9AE1), Icons.water_drop_rounded),
      TipIconKind.sleep => (const Color(0xFFEDE7FB), const Color(0xFF8B6AD6), Icons.nightlight_round),
      TipIconKind.move => (TherapyColors.cardPink, const Color(0xFFE56B9A), Icons.favorite_rounded),
    };
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: spec.$1, shape: BoxShape.circle),
      child: Icon(spec.$3, color: spec.$2),
    );
  }
}

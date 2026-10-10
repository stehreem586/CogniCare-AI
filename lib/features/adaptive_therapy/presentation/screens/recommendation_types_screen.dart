import 'package:flutter/material.dart';
import '../../data/mock_therapy_data.dart';
import '../theme/therapy_colors.dart';
import '../widgets/therapy_common.dart';

class RecommendationTypesScreen extends StatelessWidget {
  const RecommendationTypesScreen({super.key, required this.onSelect});

  final void Function(TherapyTypeItem item) onSelect;

  @override
  Widget build(BuildContext context) {
    return TherapyPage(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TherapyBackHeader(title: ''),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Adaptive Therapy\n',
                          style: TextStyle(
                            color: TherapyColors.primary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: 'Recommendations',
                          style: TextStyle(
                            color: TherapyColors.navy,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose what you would like to focus on today.',
                    style: TextStyle(color: TherapyColors.body, fontSize: 14.5),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: MockTherapyCatalog.types.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = MockTherapyCatalog.types[index];
                  return TherapyCard(
                    onTap: () => onSelect(item),
                    child: Row(
                      children: [
                        TherapyIconBubble(kind: item.iconKind, size: 52),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: TherapyColors.navy,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.subtitle,
                                style: const TextStyle(color: TherapyColors.body, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: TherapyColors.muted),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

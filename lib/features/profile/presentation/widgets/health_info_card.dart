import 'package:flutter/material.dart';

class HealthInfoCard extends StatelessWidget {
  final String title;
  final String value;

  const HealthInfoCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Text(value),
          ],
        ),
      ),
    );
  }
}

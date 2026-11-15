import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  final String title;
  final String? subtitle;

  const ProfileHeader({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!),
        ],
      ],
    );
  }
}

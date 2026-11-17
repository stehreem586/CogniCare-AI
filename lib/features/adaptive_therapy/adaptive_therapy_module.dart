export 'assessment_module.dart';

import 'package:flutter/material.dart';

/// Compatibility frame for callers that embed Module 3 in a constrained view.
class TherapyPhoneFrame extends StatelessWidget {
  const TherapyPhoneFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: ColoredBox(
          key: const ValueKey('therapy-responsive-frame'),
          color: Colors.white,
          child: child,
        ),
      );
}

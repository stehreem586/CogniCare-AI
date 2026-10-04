import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text_field.dart';

class PasswordField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const PasswordField({
    super.key,
    this.labelText = 'Password',
    this.hintText = '•••••••••',
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: labelText,
      hintText: hintText,
      icon: Icons.lock_outline_rounded,
      controller: controller,
      isPassword: true,
      validator: validator,
      onChanged: onChanged,
    );
  }
}

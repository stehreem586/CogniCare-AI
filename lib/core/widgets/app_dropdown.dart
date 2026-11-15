import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppDropdown<T> extends StatelessWidget {
  final String label;
  final String? hintText;
  final IconData icon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    required this.label,
    this.hintText,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        isExpanded: true,
        items: items,
        onChanged: onChanged,
        validator: validator,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary,
          size: 24,
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        elevation: 4,
        style: const TextStyle(
          color: AppColors.titleNavy,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          alignLabelWithHint: true,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF5A7188),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.titleNavy.withValues(alpha: 0.35),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(
              color: Color(0xFFE2E8F0),
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.8,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 1.2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}

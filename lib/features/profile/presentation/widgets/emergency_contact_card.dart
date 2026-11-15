import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class EmergencyContactCard extends StatelessWidget {
  final String name;
  final String relationship;
  final String phoneNumber;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EmergencyContactCard({
    super.key,
    required this.name,
    required this.relationship,
    required this.phoneNumber,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFEFF6FF),
            child: Icon(Icons.person_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.titleNavy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$relationship • $phoneNumber',
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/role_constants.dart';

class RoleCard extends StatelessWidget {
  final UserRole role;
  final VoidCallback onTap;
  final bool isSelected;

  const RoleCard({
    super.key,
    required this.role,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPatient = role == UserRole.patient;

    // Theme Colors for Patient vs Caregiver
    final cardBgColor = isPatient
        ? const Color(0xFFEFF6FF)
        : const Color(0xFFF0FBF4);

    final borderColor = isSelected
        ? (isPatient ? const Color(0xFF0066BD) : const Color(0xFF1B995E))
        : (isPatient ? const Color(0xFFD8E7FA) : const Color(0xFFD2F0DC));

    final iconBgColor = isPatient
        ? const Color(0xFFD4E7FC)
        : const Color(0xFFD1F5E1);

    final iconColor = isPatient
        ? const Color(0xFF0066BD)
        : const Color(0xFF1B995E);

    final titleColor = isPatient
        ? const Color(0xFF0A3967)
        : const Color(0xFF138A52);

    final subtitleColor = isPatient
        ? const Color(0xFF506882)
        : const Color(0xFF437A5C);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: borderColor,
          width: isSelected ? 2.2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? iconColor.withValues(alpha: 0.16)
                : iconColor.withValues(alpha: 0.04),
            blurRadius: isSelected ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.0),
          splashColor: iconColor.withValues(alpha: 0.1),
          highlightColor: iconColor.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
            child: Row(
              children: [
                // Circular Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _buildRoleIcon(isPatient, iconColor),
                  ),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        role.title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.description,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Right Arrow or Selection Checkmark
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? iconColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSelected
                        ? Icons.check_rounded
                        : Icons.chevron_right_rounded,
                    color: isSelected ? Colors.white : iconColor,
                    size: isSelected ? 18 : 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleIcon(bool isPatient, Color iconColor) {
    if (isPatient) {
      return Icon(
        Icons.person_rounded,
        color: iconColor,
        size: 30,
      );
    } else {
      // Custom combined heart + person icon for Caregiver
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: iconColor,
            size: 30,
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                color: Color(0xFFD1F5E1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: iconColor,
                size: 14,
              ),
            ),
          ),
        ],
      );
    }
  }
}

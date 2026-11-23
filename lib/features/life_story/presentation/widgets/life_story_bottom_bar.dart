import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';

class LifeStoryBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final bool readOnly;
  final String? patientId;
  final String? patientName;

  const LifeStoryBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.readOnly = false,
    this.patientId,
    this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (readOnly) ...[
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  onSelected: () => _handleNavigation(context, 0),
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.people_outline_rounded,
                  activeIcon: Icons.people_rounded,
                  label: 'Relatives',
                  onSelected: () => _handleNavigation(context, 3),
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.psychology_outlined,
                  activeIcon: Icons.psychology_rounded,
                  label: 'Activities',
                  onSelected: () => _handleNavigation(context, 4),
                ),
              ] else ...[
                // Caregiver navigation includes the full memory library.
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                  onSelected: () => _handleNavigation(context, 0),
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.photo_library_outlined,
                  activeIcon: Icons.photo_library_rounded,
                  label: 'Library',
                  onSelected: () => _handleNavigation(context, 1),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.newMemory,
                    arguments: {
                      'patientId': patientId,
                      'patientName': patientName,
                    },
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF58C97A), Color(0xFF2EAA55)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2EAA55,
                          ).withValues(alpha: 0.45),
                          blurRadius: 14,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.schedule_outlined,
                  activeIcon: Icons.schedule_rounded,
                  label: 'Timeline',
                  onSelected: () => _handleNavigation(context, 2),
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.hub_outlined,
                  activeIcon: Icons.hub_rounded,
                  label: 'Map',
                  onSelected: () => _handleNavigation(context, 3),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
    }

    if (index == 0 && currentIndex != 0) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.lifeStoryHub,
        arguments: {
          'patientId': patientId,
          'patientName': patientName,
          'readOnly': readOnly,
        },
      );
    } else if (index == 1 && currentIndex != 1) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.memoryLibrary,
        arguments: {
          'patientId': patientId,
          'patientName': patientName,
          'readOnly': readOnly,
        },
      );
    } else if (index == 2 && currentIndex != 2) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.lifeTimeline,
        arguments: {
          'patientId': patientId,
          'patientName': patientName,
          'readOnly': readOnly,
        },
      );
    } else if (index == 3 && currentIndex != 3) {
      if (readOnly) {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.relationshipMap,
          arguments: {
            'patientId': patientId,
            'patientName': patientName,
            'readOnly': true,
          },
        );
      } else {
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.relationshipMap,
          arguments: {
            'patientId': patientId,
            'patientName': patientName,
            'readOnly': false,
          },
        );
      }
    } else if (index == 4 && currentIndex != 4) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.recallPrompts,
        arguments: {
          'patientId': patientId,
          'patientName': patientName,
          'readOnly': true,
        },
      );
    }
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onSelected,
  }) {
    final bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: onSelected,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : const Color(0xFF64748B),
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

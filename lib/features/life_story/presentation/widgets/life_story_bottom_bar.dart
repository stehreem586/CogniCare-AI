import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';

class LifeStoryBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const LifeStoryBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
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
              // 1. Home
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Home',
                onSelected: () => _handleNavigation(context, 0),
              ),

              // 2. Library
              _buildNavItem(
                index: 1,
                icon: Icons.photo_library_outlined,
                activeIcon: Icons.photo_library_rounded,
                label: 'Library',
                onSelected: () => _handleNavigation(context, 1),
              ),

              // 3. Center Elevated Green Plus Button
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.newMemory);
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF58C97A),
                        Color(0xFF2EAA55),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2EAA55).withValues(alpha: 0.45),
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

              // 4. Timeline
              _buildNavItem(
                index: 2,
                icon: Icons.schedule_outlined,
                activeIcon: Icons.schedule_rounded,
                label: 'Timeline',
                onSelected: () => _handleNavigation(context, 2),
              ),

              // 5. Map
              _buildNavItem(
                index: 3,
                icon: Icons.hub_outlined,
                activeIcon: Icons.hub_rounded,
                label: 'Map',
                onSelected: () => _handleNavigation(context, 3),
              ),
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
      Navigator.of(context).pushReplacementNamed(AppRoutes.lifeStoryHub);
    } else if (index == 1 && currentIndex != 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.memoryLibrary);
    } else if (index == 2 && currentIndex != 2) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.lifeTimeline);
    } else if (index == 3 && currentIndex != 3) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.relationshipMap);
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

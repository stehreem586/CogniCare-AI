import 'package:flutter/material.dart';
import '../theme/therapy_colors.dart';

class TherapyBottomNav extends StatelessWidget {
  const TherapyBottomNav({
    super.key,
    required this.index,
    required this.onTap,
    this.caregiver = false,
  });

  final int index;
  final ValueChanged<int> onTap;
  final bool caregiver;

  @override
  Widget build(BuildContext context) {
    final items = caregiver
        ? const [
            (Icons.home_outlined, Icons.home_rounded, 'Home'),
            (Icons.groups_outlined, Icons.groups_rounded, 'Patients'),
            (Icons.bar_chart_outlined, Icons.bar_chart_rounded, 'Reports'),
            (Icons.menu_rounded, Icons.menu_rounded, 'More'),
          ]
        : const [
            (Icons.home_outlined, Icons.home_rounded, 'Home'),
            (Icons.grid_view_outlined, Icons.grid_view_rounded, 'Activities'),
            (Icons.insights_outlined, Icons.insights_rounded, 'Progress'),
            (Icons.menu_rounded, Icons.menu_rounded, 'More'),
          ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    icon: items[i].$1,
                    activeIcon: items[i].$2,
                    label: items[i].$3,
                    selected: i == index,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF7DE3C2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              selected ? activeIcon : icon,
              color: selected ? TherapyColors.navy : TherapyColors.muted,
              size: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
              color: selected ? TherapyColors.tealDark : TherapyColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

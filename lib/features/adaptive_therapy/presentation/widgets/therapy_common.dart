import 'package:flutter/material.dart';
import '../../data/mock_therapy_data.dart';
import '../theme/therapy_colors.dart';

class TherapyPage extends StatelessWidget {
  const TherapyPage({super.key, required this.child, this.bottomNavigationBar});

  final Widget child;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TherapyColors.bgTop,
      body: Container(
        decoration: const BoxDecoration(gradient: TherapyGradients.page),
        child: child,
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

class TherapyBackHeader extends StatelessWidget {
  const TherapyBackHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            color: TherapyColors.navy,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: TherapyColors.navy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}

class TherapyPrimaryButton extends StatelessWidget {
  const TherapyPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: TherapyGradients.primaryButton,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: TherapyColors.primary.withValues(alpha: 0.28),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TherapyOutlineButton extends StatelessWidget {
  const TherapyOutlineButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: TherapyColors.primaryDark,
          side: const BorderSide(color: Color(0xFFB7D7EE)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class TherapyCard extends StatelessWidget {
  const TherapyCard({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final Color color;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A4A7A).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class TherapyIconBubble extends StatelessWidget {
  const TherapyIconBubble({
    super.key,
    required this.kind,
    this.size = 46,
  });

  final TherapyIconKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final spec = switch (kind) {
      TherapyIconKind.leaf => (TherapyColors.cardMint, const Color(0xFF2EC4A0), Icons.spa_rounded),
      TherapyIconKind.games => (TherapyColors.cardBlue, const Color(0xFF3B9AE1), Icons.extension_rounded),
      TherapyIconKind.mindfulness => (TherapyColors.cardPurple, const Color(0xFF9B6BDB), Icons.self_improvement_rounded),
      TherapyIconKind.reminiscence => (TherapyColors.cardPink, const Color(0xFFE56B9A), Icons.menu_book_rounded),
      TherapyIconKind.routine => (const Color(0xFFEAF4FF), const Color(0xFF5B9DEF), Icons.calendar_today_rounded),
    };
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: spec.$1, shape: BoxShape.circle),
      child: Icon(spec.$3, color: spec.$2, size: size * 0.48),
    );
  }
}

class TherapyBellButton extends StatelessWidget {
  const TherapyBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.notifications_none_rounded, color: TherapyColors.navy),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(color: TherapyColors.teal, shape: BoxShape.circle),
          ),
        ),
      ],
    );
  }
}

class TherapyBadge extends StatelessWidget {
  const TherapyBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: TherapyColors.navy,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

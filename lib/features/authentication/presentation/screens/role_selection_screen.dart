import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/role_constants.dart';
import '../widgets/leaves_decoration.dart';
import '../widgets/role_card.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  UserRole? _selectedRole;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onRoleSelected(UserRole role) {
    setState(() {
      _selectedRole = role;
    });

    // Short delay for visual feedback before navigating
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        AppRoutes.signup,
        arguments: role,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgGradientTop,
              Color(0xFFF7FAFD),
              AppColors.bgGradientBottom,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main Screen Content
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),

                        // Welcome Title
                        const Text(
                          'Welcome to',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.titleNavy,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // App Title
                        const Text(
                          'CogniCare AI',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.titleNavy,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subtitle
                        const Text(
                          'Choose how you want to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.taglineBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 44),

                        // Role Option 1: Patient
                        RoleCard(
                          role: UserRole.patient,
                          isSelected: _selectedRole == UserRole.patient,
                          onTap: () => _onRoleSelected(UserRole.patient),
                        ),

                        const SizedBox(height: 4),

                        // Role Option 2: Caregiver
                        RoleCard(
                          role: UserRole.caregiver,
                          isSelected: _selectedRole == UserRole.caregiver,
                          onTap: () => _onRoleSelected(UserRole.caregiver),
                        ),

                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Decorative Leaves
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LeavesDecoration(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

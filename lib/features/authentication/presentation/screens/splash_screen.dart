import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../services/auth_state_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../widgets/splash_header_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isCheckingAuth = true;

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
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    try {
      final user = await AuthRepositoryImpl().getCurrentUser().timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      if (!mounted) return;

      if (user != null) {
        AuthStateService.instance.setCurrentUser(user);
        if (user.role == 'caregiver') {
          Navigator.of(context).pushReplacementNamed(AppRoutes.caregiverDashboard);
        } else {
          Navigator.of(context).pushReplacementNamed(AppRoutes.patientProfile);
        }
      } else {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onGetStartedPressed() {
    Navigator.of(context).pushNamed(AppRoutes.signup);
  }

  void _onSignInPressed() {
    Navigator.of(context).pushNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgGradientTop,
              Color(0xFFEAF4FD),
              AppColors.bgGradientBottom,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: _isCheckingAuth
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                children: [
                                  const SizedBox(height: 24),
                                  const SplashHeaderWidget(),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: Image.asset(
                                          AppAssets.splashIllustration,
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const SizedBox(
                                              height: 180,
                                              child: Center(
                                                child: Icon(
                                                  Icons.park,
                                                  size: 80,
                                                  color: AppColors.brandTeal,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AppButton(
                                          text: AppStrings.getStarted,
                                          onPressed: _onGetStartedPressed,
                                          height: 52,
                                          borderRadius: 26,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        const SizedBox(height: 18),
                                        GestureDetector(
                                          onTap: _onSignInPressed,
                                          behavior: HitTestBehavior.opaque,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 6.0,
                                              horizontal: 12.0,
                                            ),
                                            child: RichText(
                                              textAlign: TextAlign.center,
                                              text: const TextSpan(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF556B82),
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: AppStrings.alreadyHaveAccount,
                                                  ),
                                                  TextSpan(
                                                    text: AppStrings.signIn,
                                                    style: TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/google_icon.dart';
import '../../../../services/auth_state_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/password_field.dart';

class LoginScreen extends StatefulWidget {
  final AuthRepository? authRepository;

  const LoginScreen({super.key, this.authRepository});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final AuthRepository _authRepository;

  bool _rememberMe = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _authRepository = widget.authRepository ?? AuthRepositoryImpl();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = await _authRepository.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        if (user != null) {
          AuthStateService.instance.setCurrentUser(user);
          SnackbarUtils.showSuccess(context, 'Logged in successfully!');

          if (user.role == 'caregiver') {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.caregiverDashboard,
              (route) => false,
            );
          } else {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.patientProfile,
              (route) => false,
            );
          }
        }
      } catch (e) {
        if (!mounted) return;
        final appException = AppException.fromFirebaseException(e);
        SnackbarUtils.showError(context, appException.message);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _handleGoogleSignIn() {
    SnackbarUtils.showInfo(context, 'Google Sign In is disabled for Module 1.');
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).pushNamed(AppRoutes.forgotPassword);
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushNamed(AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.bgGradientTop,
              Color(0xFFF7FAFD),
              AppColors.bgGradientBottom,
            ],
            stops: [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppAssets.logo,
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.psychology,
                                size: 80,
                                color: AppColors.primary,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: AppStrings.appTitlePrefix,
                                  style: TextStyle(
                                    color: AppColors.titleNavy,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                TextSpan(
                                  text: AppStrings.appTitleSuffix,
                                  style: TextStyle(
                                    color: AppColors.brandTeal,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            AppStrings.tagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.taglineBlue,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.titleNavy,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Email Address',
                      hintText: 'ahmed@example.com',
                      icon: Icons.mail_outline_rounded,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                    PasswordField(
                      labelText: 'Password',
                      hintText: '•••••••••',
                      controller: _passwordController,
                      validator: Validators.validatePassword,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _rememberMe = !_rememberMe;
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    activeColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    side: const BorderSide(
                                      color: Color(0xFFCBD5E1),
                                      width: 1.5,
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _rememberMe = val ?? false;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Flexible(
                                  child: Text(
                                    'Remember me',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFF506882),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _navigateToForgotPassword,
                          behavior: HitTestBehavior.opaque,
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      text: 'Login',
                      onPressed: _handleLogin,
                      isLoading: _isLoading,
                      height: 52,
                      borderRadius: 26,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 24),
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Color(0xFFE2E8F0),
                            thickness: 1.2,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'or',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Color(0xFFE2E8F0),
                            thickness: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            color: Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GoogleLogoIcon(size: 20),
                            SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Continue with Google',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppColors.titleNavy,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: GestureDetector(
                        onTap: _navigateToSignUp,
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
                                  text: "Don't have an account? ",
                                ),
                                TextSpan(
                                  text: 'Sign Up',
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
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

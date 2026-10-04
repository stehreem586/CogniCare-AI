import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/role_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../services/auth_state_service.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../../profile/data/repositories/profile_repository_impl.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/password_field.dart';
import '../widgets/role_selector.dart';

class SignupScreen extends StatefulWidget {
  final UserRole? initialRole;
  final AuthRepository? authRepository;

  const SignupScreen({
    super.key,
    this.initialRole,
    this.authRepository,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final AuthRepository _authRepository;

  UserRole _selectedRole = UserRole.patient;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _authRepository = widget.authRepository ?? AuthRepositoryImpl();
    if (widget.initialRole != null) {
      _selectedRole = widget.initialRole!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        final roleStr = _selectedRole.key; // 'patient' or 'caregiver'
        final appUser = await _authRepository.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.trim(),
          role: roleStr,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw const AppException('Request timed out. Please check your internet connection.');
          },
        );

        if (appUser != null) {
          // Store phone number into Firestore user profile if provided
          if (_phoneController.text.trim().isNotEmpty) {
            try {
              final userProfile = UserProfile(
                uid: appUser.uid,
                role: roleStr,
                name: appUser.name,
                email: appUser.email,
                phone: _phoneController.text.trim(),
                createdAt: appUser.createdAt,
              );
              await ProfileRepositoryImpl()
                  .updateUserProfile(profile: userProfile)
                  .timeout(const Duration(seconds: 4), onTimeout: () {});
            } catch (_) {}
          }

          AuthStateService.instance.setCurrentUser(appUser);

          if (!mounted) return;

          // Display explicit confirmation message requested by user
          SnackbarUtils.showSuccess(context, 'Profile created successfully!');

          await Future.delayed(const Duration(milliseconds: 1000));
          if (!mounted) return;

          if (roleStr == 'caregiver') {
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
        } else {
          if (mounted) {
            SnackbarUtils.showError(context, 'Failed to create profile. Please try again.');
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

  void _navigateToLogin() {
    Navigator.of(context).pushNamed(AppRoutes.login);
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
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, top: 8.0),
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      size: 32,
                      color: AppColors.titleNavy,
                    ),
                    tooltip: 'Back',
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            color: AppColors.titleNavy,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Join CogniCare AI',
                          style: TextStyle(
                            color: AppColors.taglineBlue,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Role Selector Widget
                        RoleSelector(
                          selectedRole: _selectedRole,
                          onRoleChanged: (newRole) {
                            setState(() {
                              _selectedRole = newRole;
                            });
                          },
                        ),

                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Full Name',
                          hintText: 'e.g. Ayesha Khan',
                          icon: Icons.person_outline_rounded,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          validator: Validators.validateName,
                        ),
                        AppTextField(
                          label: 'Email Address',
                          hintText: 'ayesha@example.com',
                          icon: Icons.mail_outline_rounded,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                        ),
                        AppTextField(
                          label: 'Phone Number',
                          hintText: '03001234567',
                          icon: Icons.phone_outlined,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: Validators.validatePhone,
                        ),
                        PasswordField(
                          labelText: 'Password',
                          hintText: '•••••••••',
                          controller: _passwordController,
                          validator: Validators.validatePassword,
                        ),
                        PasswordField(
                          labelText: 'Confirm Password',
                          hintText: '•••••••••',
                          controller: _confirmPasswordController,
                          validator: (val) => Validators.validateConfirmPassword(
                            val,
                            _passwordController.text,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          text: 'Create Account',
                          onPressed: _handleSignUp,
                          isLoading: _isLoading,
                          height: 52,
                          borderRadius: 26,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: GestureDetector(
                            onTap: _navigateToLogin,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
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
                                      text: 'Already have an account? ',
                                    ),
                                    TextSpan(
                                      text: 'Sign In',
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
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

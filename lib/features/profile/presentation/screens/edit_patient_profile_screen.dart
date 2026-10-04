import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../services/auth_state_service.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/profile_repository_impl.dart';

class EditPatientProfileScreen extends StatefulWidget {
  final UserProfile? profile;

  const EditPatientProfileScreen({super.key, this.profile});

  @override
  State<EditPatientProfileScreen> createState() => _EditPatientProfileScreenState();
}

class _EditPatientProfileScreenState extends State<EditPatientProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;

  bool _isLoading = true;
  bool _isSaving = false;
  UserProfile? _currentProfile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentProfile == null) {
      final routeArg = ModalRoute.of(context)?.settings.arguments as UserProfile?;
      _currentProfile = routeArg ?? widget.profile;
      if (_currentProfile != null) {
        _populateFields(_currentProfile!);
        _isLoading = false;
      } else {
        _fetchCurrentProfile();
      }
    }
  }

  void _populateFields(UserProfile profile) {
    _nameController.text = profile.name;
    _phoneController.text = profile.phone ?? '';
    _dobController.text = profile.dateOfBirth ?? '';
  }

  Future<void> _fetchCurrentProfile() async {
    final firebaseUser = AuthStateService.instance.currentFirebaseUser;
    if (firebaseUser != null) {
      try {
        final profile = await ProfileRepositoryImpl().getUserProfile(uid: firebaseUser.uid);
        if (mounted) {
          setState(() {
            _currentProfile = profile ?? UserProfile(
              uid: firebaseUser.uid,
              role: 'patient',
              name: firebaseUser.displayName ?? '',
              email: firebaseUser.email ?? '',
            );
            _populateFields(_currentProfile!);
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final firstDate = DateTime(1900);
    final lastDate = now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(1960, 1, 1),
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final formatted = "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      setState(() {
        _dobController.text = formatted;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final firebaseUser = AuthStateService.instance.currentFirebaseUser;
      final targetUid = (_currentProfile?.uid.isNotEmpty == true)
          ? _currentProfile!.uid
          : firebaseUser?.uid;

      if (targetUid == null || targetUid.isEmpty) {
        SnackbarUtils.showError(context, 'User profile ID missing.');
        return;
      }

      setState(() {
        _isSaving = true;
      });

      try {
        final baseProfile = _currentProfile ?? UserProfile(
          uid: targetUid,
          role: 'patient',
          name: firebaseUser?.displayName ?? '',
          email: firebaseUser?.email ?? '',
        );

        final updatedProfile = baseProfile.copyWith(
          uid: targetUid,
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          dateOfBirth: _dobController.text.trim(),
        );

        await ProfileRepositoryImpl().updateUserProfile(profile: updatedProfile);

        if (!mounted) return;
        setState(() {
          _isSaving = false;
        });

        SnackbarUtils.showSuccess(context, 'Profile updated successfully');
        Navigator.of(context).pop(updatedProfile);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isSaving = false;
        });

        final err = AppException.fromFirebaseException(e);
        SnackbarUtils.showError(context, err.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: _isLoading
          ? const AppLoader(message: 'Loading profile data...')
          : SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Personal Information',
                        style: TextStyle(
                          color: AppColors.titleNavy,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Email: ${_currentProfile?.email ?? "N/A"}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        label: 'Full Name',
                        hintText: 'Enter full name',
                        icon: Icons.person_outline_rounded,
                        controller: _nameController,
                        validator: Validators.validateName,
                      ),
                      AppTextField(
                        label: 'Phone Number',
                        hintText: '03001234567',
                        icon: Icons.phone_outlined,
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                      ),
                      GestureDetector(
                        onTap: _selectDateOfBirth,
                        child: AbsorbPointer(
                          child: AppTextField(
                            label: 'Date of Birth',
                            hintText: 'YYYY-MM-DD',
                            icon: Icons.calendar_today_outlined,
                            controller: _dobController,
                            validator: Validators.validateDateOfBirth,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        text: 'Save Profile',
                        onPressed: _handleSave,
                        isLoading: _isSaving,
                        icon: const Icon(Icons.save_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

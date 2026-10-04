import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/cognicare_bottom_bar.dart';
import '../../../../services/auth_state_service.dart';
import '../../../authentication/data/repositories/auth_repository_impl.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../widgets/profile_avatar_widget.dart';
import '../widgets/profile_menu_item_card.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  int _selectedBottomIndex = 1;
  bool _isLoading = true;
  UserProfile? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final firebaseUser = AuthStateService.instance.currentFirebaseUser;
    if (firebaseUser != null) {
      final userProfile = await ProfileRepositoryImpl().getUserProfile(uid: firebaseUser.uid);
      if (mounted) {
        setState(() {
          _profile = userProfile ?? UserProfile(
            uid: firebaseUser.uid,
            role: 'patient',
            name: firebaseUser.displayName ?? 'Patient',
            email: firebaseUser.email ?? '',
          );
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of CogniCare AI?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthRepositoryImpl().signOut();
      AuthStateService.instance.setCurrentUser(null);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Patient Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const AppLoader(message: 'Loading profile...')
          : Container(
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      ProfileAvatarWidget(
                        name: _profile?.name ?? 'Patient',
                        roleTitle: 'Patient',
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _profile?.email ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (_profile?.phone != null && _profile!.phone!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Phone: ${_profile!.phone}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      if (_profile?.dateOfBirth != null && _profile!.dateOfBirth!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'DOB: ${_profile!.dateOfBirth}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      ProfileMenuItemCard(
                        icon: Icons.edit_outlined,
                        title: 'Edit Personal Information',
                        subtitle: 'Update name, phone number, and date of birth',
                        onTap: () async {
                          await Navigator.pushNamed(
                            context,
                            AppRoutes.editPatientProfile,
                            arguments: _profile,
                          );
                          _loadProfile();
                        },
                      ),
                      ProfileMenuItemCard(
                        icon: Icons.health_and_safety_outlined,
                        title: 'Health Information',
                        subtitle: 'Dementia stage, medical history, care notes',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.healthProfile,
                            arguments: _profile?.uid,
                          );
                        },
                      ),
                      ProfileMenuItemCard(
                        icon: Icons.contact_phone_outlined,
                        title: 'Emergency Contacts',
                        subtitle: 'Family & primary medical contacts',
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.emergencyContacts,
                            arguments: _profile?.uid,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
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
      bottomNavigationBar: CogniCareBottomBar(
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          setState(() {
            _selectedBottomIndex = index;
          });
        },
      ),
    );
  }
}

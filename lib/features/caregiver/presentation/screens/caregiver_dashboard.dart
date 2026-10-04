import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/cognicare_bottom_bar.dart';
import '../../../../services/auth_state_service.dart';
import '../../../authentication/data/repositories/auth_repository_impl.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../data/repositories/caregiver_repository_impl.dart';
import '../widgets/patient_summary_card.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  int _selectedBottomIndex = 0;
  bool _isLoading = true;
  List<UserProfile> _linkedPatients = [];
  String _caregiverName = 'Caregiver';
  String _caregiverId = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final user = AuthStateService.instance.currentFirebaseUser;
    if (user != null) {
      _caregiverId = user.uid;
      _caregiverName = user.displayName ?? 'Caregiver';

      try {
        final patients = await CaregiverRepositoryImpl().getLinkedPatientProfiles(
          caregiverId: _caregiverId,
        );
        if (mounted) {
          setState(() {
            _linkedPatients = patients;
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

  void _showLinkPatientDialog() {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    bool isLinking = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Link Patient'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter the registered patient\'s email address to request access.',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Patient Email',
                      hintText: 'patient@example.com',
                      icon: Icons.mail_outline_rounded,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLinking ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLinking
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            setDialogState(() {
                              isLinking = true;
                            });

                            try {
                              await CaregiverRepositoryImpl().linkPatientByEmail(
                                caregiverId: _caregiverId,
                                patientEmail: emailController.text.trim(),
                              );

                              if (dialogContext.mounted) {
                                SnackbarUtils.showSuccess(
                                  dialogContext,
                                  'Patient linked successfully!',
                                );
                                Navigator.pop(dialogContext);
                              }

                              if (mounted) {
                                _loadDashboardData();
                              }
                            } catch (e) {
                              setDialogState(() {
                                isLinking = false;
                              });

                              if (dialogContext.mounted) {
                                final err = AppException.fromFirebaseException(e);
                                SnackbarUtils.showError(dialogContext, err.message);
                              }
                            }
                          }
                        },
                  child: isLinking
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Link Patient'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    await AuthRepositoryImpl().signOut();
    AuthStateService.instance.setCurrentUser(null);
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded, color: AppColors.primary),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.caregiverProfile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.red),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const AppLoader(message: 'Loading dashboard...')
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: AppColors.primaryLight,
                          child: Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, $_caregiverName!',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.titleNavy,
                                ),
                              ),
                              const Text(
                                'Caregiver Portal',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.brandTeal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Linked Patients',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.titleNavy,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _showLinkPatientDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Link Patient'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _linkedPatients.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people_outline_rounded,
                                    size: 64,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'No linked patients yet.',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Click "Link Patient" above to link a patient by email.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  AppButton(
                                    text: 'Link Patient Now',
                                    onPressed: _showLinkPatientDialog,
                                    icon: const Icon(Icons.link),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: _linkedPatients.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 14),
                              itemBuilder: (context, index) {
                                final patient = _linkedPatients[index];
                                return PatientSummaryCard(
                                  patientName: patient.name,
                                  dementiaStage: 'Mild',
                                  relationship: 'Linked Patient',
                                  onViewDetails: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.linkedPatient,
                                      arguments: patient,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: CogniCareBottomBar(
        currentIndex: _selectedBottomIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, AppRoutes.caregiverProfile);
          } else {
            setState(() {
              _selectedBottomIndex = index;
            });
          }
        },
      ),
    );
  }
}

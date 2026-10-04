import 'package:flutter/material.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../profile/data/models/health_profile.dart';
import '../../../profile/data/models/user_profile.dart';
import '../../data/repositories/caregiver_repository_impl.dart';

class LinkedPatientScreen extends StatefulWidget {
  final UserProfile? patientProfile;

  const LinkedPatientScreen({super.key, this.patientProfile});

  @override
  State<LinkedPatientScreen> createState() => _LinkedPatientScreenState();
}

class _LinkedPatientScreenState extends State<LinkedPatientScreen> {
  bool _isLoading = true;
  UserProfile? _patient;
  HealthProfile? _healthProfile;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_patient == null) {
      final routeArg = ModalRoute.of(context)?.settings.arguments as UserProfile?;
      _patient = routeArg ?? widget.patientProfile;
      if (_patient != null) {
        _loadPatientHealthData();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadPatientHealthData() async {
    if (_patient == null) return;
    try {
      final health = await CaregiverRepositoryImpl().getPatientHealthProfile(
        patientId: _patient!.uid,
      );
      if (mounted) {
        setState(() {
          _healthProfile = health;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_patient?.name ?? 'Patient Details'),
        actions: [
          if (_patient != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Patient Profile',
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  AppRoutes.editPatientProfile,
                  arguments: _patient,
                );
                _loadPatientHealthData();
              },
            ),
        ],
      ),
      body: _isLoading
          ? const AppLoader(message: 'Loading patient information...')
          : _patient == null
              ? const Center(child: Text('Patient not found.'))
              : SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: AppColors.primary,
                                    child: Text(
                                      _patient!.name.isNotEmpty ? _patient!.name[0].toUpperCase() : 'P',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _patient!.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.titleNavy,
                                          ),
                                        ),
                                        Text(
                                          _patient!.email,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Phone: ${_patient!.phone ?? "Not provided"}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    'DOB: ${_patient!.dateOfBirth ?? "Not provided"}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Health Information Section
                        const Text(
                          'Health Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.titleNavy,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Dementia Stage:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.titleNavy,
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      _healthProfile?.dementiaStage ?? 'Mild',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: AppColors.brandTeal,
                                    padding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Medical History:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.titleNavy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (_healthProfile?.medicalHistory.isEmpty ?? true)
                                    ? 'No medical history recorded.'
                                    : _healthProfile!.medicalHistory,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Care Notes:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.titleNavy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                (_healthProfile?.careNotes.isEmpty ?? true)
                                    ? 'No special care notes recorded.'
                                    : _healthProfile!.careNotes,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons for Caregiver
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.healthProfile,
                                    arguments: _patient!.uid,
                                  );
                                },
                                icon: const Icon(Icons.health_and_safety_outlined),
                                label: const Text('Update Health'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.emergencyContacts,
                                    arguments: _patient!.uid,
                                  );
                                },
                                icon: const Icon(Icons.contact_phone_outlined),
                                label: const Text('Emergency Contacts'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

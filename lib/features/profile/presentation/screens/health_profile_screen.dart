import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_dropdown.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../services/auth_state_service.dart';
import '../../data/models/health_profile.dart';
import '../../data/repositories/profile_repository_impl.dart';

class HealthProfileScreen extends StatefulWidget {
  final String? patientId;

  const HealthProfileScreen({super.key, this.patientId});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _medicalHistoryController;
  late final TextEditingController _careNotesController;

  String _dementiaStage = 'Mild';
  bool _isLoading = true;
  bool _isSaving = false;
  String _targetUid = '';

  final List<String> _dementiaStages = const [
    'Mild',
    'Moderate',
    'Severe',
    'Unspecified',
  ];

  @override
  void initState() {
    super.initState();
    _medicalHistoryController = TextEditingController();
    _careNotesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_targetUid.isEmpty) {
      final routeArg = ModalRoute.of(context)?.settings.arguments as String?;
      _targetUid = routeArg ?? widget.patientId ?? AuthStateService.instance.currentFirebaseUser?.uid ?? '';
      _loadHealthProfile();
    }
  }

  @override
  void dispose() {
    _medicalHistoryController.dispose();
    _careNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadHealthProfile() async {
    if (_targetUid.isEmpty) return;

    try {
      final healthProfile = await ProfileRepositoryImpl().getHealthProfile(uid: _targetUid);
      if (mounted) {
        setState(() {
          if (healthProfile != null) {
            _dementiaStage = _dementiaStages.contains(healthProfile.dementiaStage)
                ? healthProfile.dementiaStage
                : 'Mild';
            _medicalHistoryController.text = healthProfile.medicalHistory;
            _careNotesController.text = healthProfile.careNotes;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        final err = AppException.fromFirebaseException(e);
        SnackbarUtils.showError(context, err.message);
      }
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      try {
        final updatedHealth = HealthProfile(
          dementiaStage: _dementiaStage,
          medicalHistory: _medicalHistoryController.text.trim(),
          careNotes: _careNotesController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await ProfileRepositoryImpl().updateHealthProfile(
          uid: _targetUid,
          profile: updatedHealth,
        );

        if (!mounted) return;
        setState(() {
          _isSaving = false;
        });

        SnackbarUtils.showSuccess(context, 'Health profile updated successfully!');
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
        title: const Text('Health Information'),
      ),
      body: _isLoading
          ? const AppLoader(message: 'Loading health profile...')
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
                        'Health Profile',
                        style: TextStyle(
                          color: AppColors.titleNavy,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Manage dementia stage, medical history, and care notes.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Dementia Stage Dropdown
                      AppDropdown<String>(
                        label: 'Dementia Stage',
                        hintText: 'Select dementia stage',
                        icon: Icons.health_and_safety_outlined,
                        value: _dementiaStage,
                        items: _dementiaStages.map((stage) {
                          return DropdownMenuItem<String>(
                            value: stage,
                            child: Text(stage),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              _dementiaStage = newValue;
                            });
                          }
                        },
                      ),

                      // Medical History
                      AppTextField(
                        label: 'Medical History',
                        hintText: 'Describe pre-existing conditions, past surgeries, or medical history...',
                        icon: Icons.assignment_outlined,
                        controller: _medicalHistoryController,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                      ),

                      // Special Care Notes
                      AppTextField(
                        label: 'Special Care Notes',
                        hintText: 'Daily routines, dietary preferences, special care instructions...',
                        icon: Icons.note_alt_outlined,
                        controller: _careNotesController,
                        maxLines: 4,
                        keyboardType: TextInputType.multiline,
                      ),

                      const SizedBox(height: 28),

                      // Save Button
                      AppButton(
                        text: 'Save Health Information',
                        onPressed: _handleSave,
                        isLoading: _isSaving,
                        icon: const Icon(Icons.save_outlined),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../services/auth_state_service.dart';
import '../../data/models/emergency_contact.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../widgets/emergency_contact_card.dart';

class EmergencyContactsScreen extends StatefulWidget {
  final String? patientId;

  const EmergencyContactsScreen({super.key, this.patientId});

  @override
  State<EmergencyContactsScreen> createState() => _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  String _targetUid = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_targetUid.isEmpty) {
      final routeArg = ModalRoute.of(context)?.settings.arguments as String?;
      _targetUid = routeArg ?? widget.patientId ?? AuthStateService.instance.currentFirebaseUser?.uid ?? '';
    }
  }

  void _showAddEditContactDialog([EmergencyContact? contact]) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: contact?.name ?? '');
    final relationController = TextEditingController(text: contact?.relationship ?? '');
    final phoneController = TextEditingController(text: contact?.phone ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(contact == null ? 'Add Emergency Contact' : 'Edit Emergency Contact'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTextField(
                        label: 'Contact Name',
                        hintText: 'e.g. Dr. Ali / Sara Khan',
                        icon: Icons.person_outline_rounded,
                        controller: nameController,
                        validator: Validators.validateName,
                      ),
                      AppTextField(
                        label: 'Relationship',
                        hintText: 'e.g. Daughter / Primary Physician',
                        icon: Icons.people_outline_rounded,
                        controller: relationController,
                        validator: (v) => Validators.validateRequired(v, 'Relationship'),
                      ),
                      AppTextField(
                        label: 'Phone Number',
                        hintText: '03001234567',
                        icon: Icons.phone_outlined,
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (formKey.currentState?.validate() ?? false) {
                            setDialogState(() {
                              isSaving = true;
                            });

                            try {
                              if (contact == null) {
                                await ProfileRepositoryImpl().addEmergencyContact(
                                  uid: _targetUid,
                                  contact: EmergencyContact(
                                    id: '',
                                    name: nameController.text.trim(),
                                    relationship: relationController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    createdAt: DateTime.now(),
                                  ),
                                );
                                if (dialogContext.mounted) {
                                  SnackbarUtils.showSuccess(dialogContext, 'Contact added successfully');
                                }
                              } else {
                                await ProfileRepositoryImpl().updateEmergencyContact(
                                  uid: _targetUid,
                                  contact: contact.copyWith(
                                    name: nameController.text.trim(),
                                    relationship: relationController.text.trim(),
                                    phone: phoneController.text.trim(),
                                  ),
                                );
                                if (dialogContext.mounted) {
                                  SnackbarUtils.showSuccess(dialogContext, 'Contact updated successfully');
                                }
                              }
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                            } catch (e) {
                              setDialogState(() {
                                isSaving = false;
                              });
                              if (dialogContext.mounted) {
                                final err = AppException.fromFirebaseException(e);
                                SnackbarUtils.showError(dialogContext, err.message);
                              }
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(contact == null ? 'Add Contact' : 'Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleDeleteContact(EmergencyContact contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name} from emergency contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ProfileRepositoryImpl().deleteEmergencyContact(
          uid: _targetUid,
          contactId: contact.id,
        );
        if (mounted) {
          SnackbarUtils.showSuccess(context, 'Emergency contact deleted.');
        }
      } catch (e) {
        if (mounted) {
          final err = AppException.fromFirebaseException(e);
          SnackbarUtils.showError(context, err.message);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Emergency Contacts'),
      ),
      body: _targetUid.isEmpty
          ? const AppLoader(message: 'Loading contacts...')
          : StreamBuilder<List<EmergencyContact>>(
              stream: ProfileRepositoryImpl().streamEmergencyContacts(uid: _targetUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const AppLoader(message: 'Loading contacts...');
                }

                if (snapshot.hasError) {
                  return AppErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(() {}),
                  );
                }

                final contacts = snapshot.data ?? [];

                return SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Emergency Contacts',
                          style: TextStyle(
                            color: AppColors.titleNavy,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Keep quick emergency contact information updated.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Add Contact',
                          onPressed: () => _showAddEditContactDialog(),
                          icon: const Icon(Icons.add_call),
                          height: 48,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: contacts.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.contact_phone_outlined,
                                        size: 64,
                                        color: AppColors.textMuted,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'No emergency contacts added yet.',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: contacts.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final contact = contacts[index];
                                    return EmergencyContactCard(
                                      name: contact.name,
                                      relationship: contact.relationship,
                                      phoneNumber: contact.phone,
                                      onEdit: () => _showAddEditContactDialog(contact),
                                      onDelete: () => _handleDeleteContact(contact),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

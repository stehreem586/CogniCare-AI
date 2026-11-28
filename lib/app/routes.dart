import 'package:flutter/material.dart';
import '../core/constants/role_constants.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/authentication/presentation/screens/role_selection_screen.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/signup_screen.dart';
import '../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../features/profile/presentation/screens/patient_profile_screen.dart';
import '../features/profile/presentation/screens/caregiver_profile_screen.dart';
import '../features/profile/presentation/screens/health_profile_screen.dart';
import '../features/profile/presentation/screens/emergency_contacts_screen.dart';
import '../features/profile/presentation/screens/edit_patient_profile_screen.dart';
import '../features/caregiver/presentation/screens/caregiver_dashboard.dart';
import '../features/caregiver/presentation/screens/linked_patient_screen.dart';
import '../features/adaptive_therapy/assessment_module.dart';
import '../features/adaptive_therapy/data/models/therapy_models.dart';
import '../features/life_story/presentation/screens/life_story_hub_screen.dart';
import '../features/life_story/presentation/screens/new_memory_screen.dart';
import '../features/life_story/presentation/screens/memory_library_screen.dart';
import '../features/life_story/presentation/screens/life_timeline_screen.dart';
import '../features/life_story/presentation/screens/relationship_map_screen.dart';
import '../features/life_story/presentation/screens/recall_prompts_screen.dart';
import '../features/profile/data/models/user_profile.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String roleSelection = '/role-selection';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String patientProfile = '/patient-profile';
  static const String caregiverProfile = '/caregiver-profile';
  static const String healthProfile = '/health-profile';
  static const String emergencyContacts = '/emergency-contacts';
  static const String editPatientProfile = '/edit-patient-profile';
  static const String caregiverDashboard = '/caregiver-dashboard';
  static const String linkedPatient = '/linked-patient';
  static const String adaptiveTherapy = '/adaptive-therapy';
  static const String lifeStoryHub = '/life-story-hub';
  static const String newMemory = '/new-memory';
  static const String memoryLibrary = '/memory-library';
  static const String lifeTimeline = '/life-timeline';
  static const String relationshipMap = '/relationship-map';
  static const String recallPrompts = '/recall-prompts';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    roleSelection: (context) => const RoleSelectionScreen(),
    login: (context) => const LoginScreen(),
    signup: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      UserRole? initialRole;
      if (args is UserRole) {
        initialRole = args;
      } else if (args is String) {
        initialRole = UserRole.fromString(args);
      }
      return SignupScreen(initialRole: initialRole);
    },
    forgotPassword: (context) => const ForgotPasswordScreen(),
    patientProfile: (context) => const PatientProfileScreen(),
    caregiverProfile: (context) => const CaregiverProfileScreen(),
    healthProfile: (context) => const HealthProfileScreen(),
    emergencyContacts: (context) => const EmergencyContactsScreen(),
    editPatientProfile: (context) => const EditPatientProfileScreen(),
    caregiverDashboard: (context) => const CaregiverDashboard(),
    linkedPatient: (context) => const LinkedPatientScreen(),
    lifeStoryHub: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is UserProfile) {
        return LifeStoryHubScreen(
          patientId: args.uid,
          patientName: args.name,
          // This route is used from the caregiver's linked-patient screen.
          // The linked patient's role must not change the caregiver's view
          // mode; the signed-in viewer determines whether this is read-only.
          readOnly: false,
        );
      }
      final map = args is Map ? args : const {};
      return LifeStoryHubScreen(
        patientId: map['patientId'] as String?,
        patientName: map['patientName'] as String?,
        readOnly: map['readOnly'] == true,
      );
    },
    newMemory: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final map = args is Map ? args : const {};
      return NewMemoryScreen(patientId: map['patientId'] as String?);
    },
    memoryLibrary: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final map = args is Map ? args : const {};
      return MemoryLibraryScreen(
        patientId: map['patientId'] as String?,
        readOnly: map['readOnly'] == true,
      );
    },
    lifeTimeline: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final map = args is Map ? args : const {};
      return LifeTimelineScreen(
        patientId: map['patientId'] as String?,
        patientName: map['patientName'] as String?,
        readOnly: map['readOnly'] == true,
      );
    },
    relationshipMap: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final map = args is Map ? args : const {};
      return RelationshipMapScreen(
        patientId: map['patientId'] as String?,
        patientName: map['patientName'] as String?,
        readOnly: map['readOnly'] == true,
      );
    },
    recallPrompts: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      final map = args is Map ? args : const {};
      return RecallPromptsScreen(
        patientId: map['patientId'] as String?,
        readOnly: map['readOnly'] == true,
      );
    },
    adaptiveTherapy: (context) {
      final tab = ModalRoute.of(context)?.settings.arguments;
      return AssessmentModule(
        initialTab: tab is TherapyModuleTab ? tab : TherapyModuleTab.home,
      );
    },
  };
}

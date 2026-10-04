import 'package:flutter/material.dart';
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

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        roleSelection: (context) => const RoleSelectionScreen(),
        login: (context) => const LoginScreen(),
        signup: (context) => const SignupScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
        patientProfile: (context) => const PatientProfileScreen(),
        caregiverProfile: (context) => const CaregiverProfileScreen(),
        healthProfile: (context) => const HealthProfileScreen(),
        emergencyContacts: (context) => const EmergencyContactsScreen(),
        editPatientProfile: (context) => const EditPatientProfileScreen(),
        caregiverDashboard: (context) => const CaregiverDashboard(),
        linkedPatient: (context) => const LinkedPatientScreen(),
      };
}

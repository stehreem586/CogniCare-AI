enum UserRole {
  patient,
  caregiver;

  String get title {
    switch (this) {
      case UserRole.patient:
        return 'Patient';
      case UserRole.caregiver:
        return 'Caregiver';
    }
  }

  String get description {
    switch (this) {
      case UserRole.patient:
        return 'I am a person with dementia';
      case UserRole.caregiver:
        return 'I am a family member or caregiver';
    }
  }

  String get key => name;

  static UserRole fromString(String? value) {
    if (value?.toLowerCase() == RoleConstants.caregiver) {
      return UserRole.caregiver;
    }
    return UserRole.patient;
  }
}

class RoleConstants {
  RoleConstants._();

  static const String patient = 'patient';
  static const String caregiver = 'caregiver';

  static const String patientTitle = 'Patient';
  static const String patientDescription = 'I am a person with dementia';

  static const String caregiverTitle = 'Caregiver';
  static const String caregiverDescription = 'I am a family member or caregiver';
}

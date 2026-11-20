class FirestoreConstants {
  FirestoreConstants._();

  // Collection names
  static const String usersCollection = 'users';
  static const String healthProfileSubcollection = 'healthProfile';
  static const String healthProfileDocId = 'info';
  static const String emergencyContactsSubcollection = 'emergencyContacts';
  static const String caregiverPatientLinksCollection = 'caregiverPatientLinks';

  // User document field keys
  static const String fieldUid = 'uid';
  static const String fieldRole = 'role';
  static const String fieldName = 'name';
  static const String fieldEmail = 'email';
  static const String fieldPhone = 'phone';
  static const String fieldDateOfBirth = 'dateOfBirth';
  static const String fieldCreatedAt = 'createdAt';

  // Health Profile field keys
  static const String fieldDementiaStage = 'dementiaStage';
  static const String fieldMedicalHistory = 'medicalHistory';
  static const String fieldCareNotes = 'careNotes';
  static const String fieldUpdatedAt = 'updatedAt';

  // Emergency Contact field keys
  static const String fieldRelationship = 'relationship';

  // Caregiver Patient Link field keys
  static const String fieldCaregiverId = 'caregiverId';
  static const String fieldPatientId = 'patientId';

  // Module 4 Life Story & Memory constants
  static const String memoriesCollection = 'memories';
  static const String fieldMemoryTitle = 'title';
  static const String fieldMemoryDate = 'date';
  static const String fieldMemoryPlace = 'place';
  static const String fieldMemoryEra = 'era';
  static const String fieldTaggedPeople = 'taggedPeople';
  static const String fieldPhotoUrl = 'photoUrl';
  static const String fieldPhotoBase64 = 'photoBase64';
  static const String fieldIllustrationKey = 'illustrationKey';
  static const String fieldAudioDuration = 'audioDurationSeconds';
  static const String fieldAiSuggestions = 'aiSuggestions';
}

import 'package:firebase_auth/firebase_auth.dart';

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException(this.message, {this.code, this.originalException});

  @override
  String toString() => message;

  factory AppException.fromFirebaseException(dynamic exception) {
    if (exception is FirebaseAuthException) {
      switch (exception.code) {
        case 'user-not-found':
          return AppException(
            'No registered user account found with this email address.',
            code: exception.code,
            originalException: exception,
          );
        case 'wrong-password':
        case 'invalid-credential':
          return AppException(
            'Invalid email or password. Please check your credentials.',
            code: exception.code,
            originalException: exception,
          );
        case 'email-already-in-use':
          return AppException(
            'An account already exists with this email address.',
            code: exception.code,
            originalException: exception,
          );
        case 'invalid-email':
          return AppException(
            'Please enter a valid email address.',
            code: exception.code,
            originalException: exception,
          );
        case 'weak-password':
          return AppException(
            'Password is too weak. Please use at least 6 characters.',
            code: exception.code,
            originalException: exception,
          );
        case 'user-disabled':
          return AppException(
            'This user account has been disabled. Please contact support.',
            code: exception.code,
            originalException: exception,
          );
        case 'too-many-requests':
          return AppException(
            'Too many failed attempts. Please try again later.',
            code: exception.code,
            originalException: exception,
          );
        case 'network-request-failed':
          return const AppException('Network error. Please check your internet connection.');
        default:
          return AppException(
            exception.message ?? 'An authentication error occurred.',
            code: exception.code,
            originalException: exception,
          );
      }
    }

    if (exception is FirebaseException) {
      switch (exception.code) {
        case 'permission-denied':
          return AppException(
            'Access denied. You do not have permission to view or edit this data.',
            code: exception.code,
            originalException: exception,
          );
        case 'unavailable':
          return const AppException('Service is temporarily unavailable. Please try again later.');
        case 'not-found':
          return const AppException('Requested resource was not found.');
        default:
          return AppException(
            exception.message ?? 'A database error occurred.',
            code: exception.code,
            originalException: exception,
          );
      }
    }

    if (exception is AppException) {
      return exception;
    }

    return AppException(
      exception?.toString() ?? 'An unexpected error occurred.',
      originalException: exception,
    );
  }
}

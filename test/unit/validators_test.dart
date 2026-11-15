import 'package:flutter_test/flutter_test.dart';
import 'package:cognicare_ai/core/utils/validators.dart';

void main() {
  group('Validators Unit Tests', () {
    test('validateEmail returns error for null or invalid email', () {
      expect(Validators.validateEmail(null), 'Email is required');
      expect(Validators.validateEmail(''), 'Email is required');
      expect(Validators.validateEmail('invalid-email'), 'Enter a valid email address');
      expect(Validators.validateEmail('test@domain'), 'Enter a valid email address');
    });

    test('validateEmail returns null for valid email', () {
      expect(Validators.validateEmail('user@cognicare.ai'), null);
      expect(Validators.validateEmail('patient123@gmail.com'), null);
    });

    test('validatePassword validates length and presence', () {
      expect(Validators.validatePassword(null), 'Password is required');
      expect(Validators.validatePassword('12345'), 'Password must be at least 6 characters long');
      expect(Validators.validatePassword('secure123'), null);
    });

    test('validateConfirmPassword checks match', () {
      expect(Validators.validateConfirmPassword('pass123', 'pass456'), 'Passwords do not match');
      expect(Validators.validateConfirmPassword('pass123', 'pass123'), null);
    });

    test('validatePhone checks validity', () {
      expect(Validators.validatePhone(null), 'Phone number is required');
      expect(Validators.validatePhone('123'), 'Enter a valid phone number');
      expect(Validators.validatePhone('03001234567'), null);
    });
  });
}

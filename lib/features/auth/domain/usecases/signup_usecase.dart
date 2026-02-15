import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Sign Up Use Case with Validation
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AppUser> call({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // Validate email
    if (email.trim().isEmpty) {
      throw Exception('Email cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Please enter a valid email address');
    }

    // Validate password
    if (password.isEmpty) {
      throw Exception('Password cannot be empty');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    if (!_hasUpperCase(password)) {
      throw Exception('Password must contain at least one uppercase letter');
    }

    if (!_hasLowerCase(password)) {
      throw Exception('Password must contain at least one lowercase letter');
    }

    if (!_hasNumber(password)) {
      throw Exception('Password must contain at least one number');
    }

    // Validate full name
    if (fullName.trim().isEmpty) {
      throw Exception('Full name cannot be empty');
    }

    if (fullName.trim().length < 2) {
      throw Exception('Full name must be at least 2 characters');
    }

    // Call repository
    return await repository.signUp(
      email: email.trim(),
      password: password,
      fullName: fullName.trim(),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  bool _hasUpperCase(String password) {
    return password.contains(RegExp(r'[A-Z]'));
  }

  bool _hasLowerCase(String password) {
    return password.contains(RegExp(r'[a-z]'));
  }

  bool _hasNumber(String password) {
    return password.contains(RegExp(r'[0-9]'));
  }
}
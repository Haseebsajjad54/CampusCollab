import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AppUser> call({
    required String email,
    required String password,
    required String fullName,
  }) async {
    // Validation
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email address');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    if (fullName.trim().length < 2) {
      throw Exception('Name must be at least 2 characters');
    }

    // Call repository
    return await repository.signUp(
      email: email.trim(),
      password: password,
      fullName: fullName.trim(),
    );
  }
}
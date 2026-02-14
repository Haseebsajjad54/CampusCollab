import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AppUser> call(String email, String password) {
    return repository.signUp(email: email, password: password);
  }
}

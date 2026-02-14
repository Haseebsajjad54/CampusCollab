import '../entities/user.dart';

abstract class AuthRepository {
  Future<AppUser> signUp({
    required String email,
    required String password,
  });

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  AppUser? getCurrentUser();
}

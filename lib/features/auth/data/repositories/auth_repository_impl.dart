import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final user = await remoteDataSource.signUp(email, password);

    return AppUser(
      id: user.id,
      email: user.email ?? '',
    );
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.signIn(email, password);

    return AppUser(
      id: user.id,
      email: user.email ?? '',
    );
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  AppUser? getCurrentUser() {
    final user = remoteDataSource.getCurrentUser();

    if (user == null) return null;

    return AppUser(
      id: user.id,
      email: user.email ?? '',
    );
  }
}

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;


  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);

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
      fullName: '',
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
      fullName: '',
    );
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final cachedUser = await localDataSource.getCachedUser();

    if (cachedUser != null) {
      return cachedUser;
    }

    final supabaseUser = remoteDataSource.getCurrentUser();
    if (supabaseUser == null) return null;

    return UserModel.fromSupabaseUser(supabaseUser);
  }
}

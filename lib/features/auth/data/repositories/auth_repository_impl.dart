import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
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
    // Sign up user (profile auto-created by trigger!)
    final user = await remoteDataSource.signUp(
       email,
       password,
       fullName,
    );

    // Fetch the auto-created profile
    final profile = await remoteDataSource.getProfile(user.id);

    final appUser = AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: profile?['full_name'] ?? fullName,
    );

    // Cache user
    await localDataSource.cacheUser(UserModel.fromEntity(appUser));

    return appUser;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = await remoteDataSource.signIn(email, password);

    // Fetch profile
    final profile = await remoteDataSource.getProfile(user.id);

    final appUser = AppUser(
      id: user.id,
      email: user.email ?? '',
      fullName: profile?['full_name'] ?? '',
    );

    // Cache user
    await localDataSource.cacheUser(UserModel.fromEntity(appUser));

    return appUser;
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
    await localDataSource.clearUser();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    // Try cache first
    final cachedUser = await localDataSource.getCachedUser();
    if (cachedUser != null) {
      return cachedUser;
    }

    // Get from Supabase
    final supabaseUser = remoteDataSource.getCurrentUser();
    if (supabaseUser == null) return null;

    // Fetch profile
    final profile = await remoteDataSource.getProfile(supabaseUser.id);

    return AppUser(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      fullName: profile?['full_name'] ?? '',
    );
  }
}